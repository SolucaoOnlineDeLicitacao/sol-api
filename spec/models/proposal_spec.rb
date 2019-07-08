require 'rails_helper'

RSpec.describe Proposal, type: :model do

  describe 'enums' do
    let(:expected_status) do
      {
        draft: 0, sent: 1, triage: 2, coop_refused: 3, refused: 4,
        coop_accepted: 5, accepted: 6, failure: 7, draw: 8, abandoned: 9
      }
    end

    it { is_expected.to define_enum_for(:status).with_values(expected_status) }
  end

  describe 'associations' do
    it { is_expected.to belong_to :bidding }
    it { is_expected.to belong_to :provider }

    it { is_expected.to have_one(:contract).dependent(:nullify) }

    it { is_expected.to have_many(:lot_proposals).dependent(:destroy) }
    it { is_expected.to have_many(:lot_group_item_lot_proposals).through(:lot_proposals) }
    it do
      is_expected.to have_many(:event_proposal_status_changes).
        class_name(Events::ProposalStatusChange).dependent(:destroy)
    end
    it do
      is_expected.to have_many(:event_cancel_proposal_refuseds).
        class_name(Events::CancelProposalRefused).dependent(:destroy)
    end
    it do
      is_expected.to have_many(:event_cancel_proposal_accepteds).
        class_name(Events::CancelProposalAccepted).dependent(:destroy)
    end
    it { is_expected.to have_many(:lots).through(:bidding) }
    it { is_expected.to have_many(:classifications).through(:lot_group_item_lot_proposals).source(:classification) }
    it { is_expected.to have_many(:current_lots).through(:lot_proposals).source(:lot) }
    it { is_expected.to have_many(:concurrent_proposals).through(:current_lots).source(:proposals) }
  end

  describe 'validations' do
    it_behaves_like "bidding_modality_validations"

    it { is_expected.to validate_presence_of :bidding }
    it { is_expected.to validate_presence_of :provider }
    it { is_expected.to validate_presence_of :status }

    describe 'lot_proposals' do
      let(:proposal) { build(:proposal) }

      subject { proposal }

      context 'when draft' do
        before { proposal.status = :draft }

        context 'when <= 0' do
          before do
            proposal.lot_proposals.destroy_all
            proposal.valid?
          end

          it { is_expected.not_to include_error_key_for(:lot_proposals, :too_short) }
        end
      end

      context 'when abandoned' do
        before { proposal.status = :abandoned }

        context 'when <= 0' do
          before do
            proposal.lot_proposals.destroy_all
            proposal.valid?
          end

          it { is_expected.not_to include_error_key_for(:lot_proposals, :too_short) }
        end
      end

      context 'when not draft or abandoned' do
        before { proposal.status = :sent }

        context 'when <= 0' do
          before do
            proposal.lot_proposals.destroy_all
            proposal.valid?
          end

          it { is_expected.to include_error_key_for(:lot_proposals, :too_short) }
        end

        context 'when > 0' do
          before { proposal.save }

          it { is_expected.not_to include_error_key_for(:lot_proposals, :too_short) }
        end
      end
    end

    context 'proposal_import' do
      it_behaves_like "imports_running with", :proposal_import
    end

    context 'lot_proposal_import' do
      it_behaves_like "imports_running with", :lot_proposal_import
    end
  end

  describe 'scopes' do
    let(:bidding) { create(:bidding, status: 1) }

    let!(:proposal) { create(:proposal, bidding: bidding, status: :sent) }
    let!(:proposal_2) { create(:proposal, bidding: bidding, status: :sent) }
    let!(:proposal_3) { create(:proposal, bidding: bidding, status: :sent) }

    before do
      proposal.update_column(:price_total, 5_000)

      proposal_2.update_column(:price_total, 2_000)
      proposal_2.update_column(:sent_updated_at, DateTime.now+1.hour)

      proposal_3.update_column(:price_total, 1_000)
      proposal_3.update_column(:sent_updated_at, DateTime.now)
    end

    describe 'all_lower' do
      it { expect(Proposal.all_lower).to eq [proposal_3, proposal_2, proposal] }
    end

    describe 'next_proposal' do
      it { expect(Proposal.next_proposal).to eq proposal_3 }
    end

    describe 'not_failure' do
      before { proposal_3.failure! }
      it { expect(Proposal.not_failure).to match_array [proposal, proposal_2] }
    end

    describe 'not_draft' do
      before { proposal_2.draft! }
      it { expect(bidding.proposals.not_draft).to match_array [proposal, proposal_3] }
    end

    describe 'not_draft_or_abandoned' do
      before { proposal_3.draft!; proposal_2.abandoned! }
      it { expect(Proposal.not_draft_or_abandoned).to match_array [proposal] }
    end

    describe 'concurrent_not_failure' do
      before { proposal_3.failure! }
      it { expect(proposal.concurrent_not_failure).to match_array [proposal_2, proposal] }
    end

    describe 'lots_name' do
      let(:name) { proposal.lot_proposals.map(&:lot).map(&:name).to_sentence }
      it { expect(proposal.lots_name).to eq name }
    end

    describe 'accepteds_without_contracts' do
      let(:user) { create(:user) }
      let!(:contract) do
        create(:contract, proposal: proposal, user: user,
                          user_signed_at: DateTime.current)
      end

      let(:proposals) { bidding.proposals }

      let(:accepteds_without_contracts) { proposals.accepteds_without_contracts }

      before { proposal.accepted!; proposal_2.accepted! }

      it { expect(accepteds_without_contracts).to eq [ proposal_2 ] }
    end

  end

  describe 'nesteds' do
    it { is_expected.to accept_nested_attributes_for :lot_proposals }
  end

  describe 'sortable' do
    it { expect(described_class.default_sort_column).to eq 'proposals.price_total' }
  end

  describe 'methods' do
    describe '.lower' do
      let(:bidding) { create(:bidding, status: 1) }

      let!(:proposal) { create(:proposal, bidding: bidding) }
      let!(:proposal_2) { create(:proposal, bidding: bidding) }

      before do
        proposal.update_column(:price_total, 5_000)
        proposal_2.update_column(:price_total, 2_000)
      end

      it { expect(Proposal.lower).to eq proposal_2 }
    end

    describe '.search' do
      it { expect(LotProposal.search).to eq LotProposal.all }
    end

    describe '.was_draft?' do
      with_versioning do
        let(:proposal) { create(:proposal, status: from) }

        before { proposal.update!(status: to) }

        subject { proposal.was_draft? }

        context 'when changing from draft to sent' do
          let(:from) { :draft }
          let(:to)   { :sent }

          it { is_expected.to be_truthy }
        end

        context 'when changing from sent to triage' do
          let(:from) { :sent }
          let(:to)   { :triage }

          it { is_expected.to be_falsey }
        end
      end
    end

    describe '.was_draw?' do
      with_versioning do
        let(:proposal) { create(:proposal, status: from) }

        before { proposal.update!(status: to) }

        subject { proposal.was_draw? }

        context 'when changing from draw to sent' do
          let(:from) { :draw }
          let(:to)   { :sent }

          it { is_expected.to be_truthy }
        end

        context 'when changing from sent to triage' do
          let(:from) { :sent }
          let(:to)   { :triage }

          it { is_expected.to be_falsey }
        end
      end
    end
  end

  describe 'callbacks' do
    describe 'update_price_total' do
      let!(:resource) { create(:proposal) }
      let(:lot_proposal) { resource.lot_proposals.first }
      let(:lot_proposal2) { create(:lot_proposal, proposal: resource) }

      let!(:total) { lot_proposal.price_total + lot_proposal2.price_total }

      before { resource.save }

      it { expect(resource.price_total.to_d).to eq total.to_d }
    end
  end

  describe 'behaviors' do
    it { is_expected.to be_versionable }
  end
end
