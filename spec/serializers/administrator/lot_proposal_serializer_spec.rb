require 'rails_helper'

RSpec.describe Administrator::LotProposalSerializer, type: :serializer do
  let(:object) { create :lot_proposal }
  let!(:proposal) { object.proposal }
  let(:provider) { object.provider }

  subject { format_json(described_class, object) }

  describe 'attributes' do
    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'status' => object.status }
    it { is_expected.to include 'bidding_id' => object.lot.bidding_id }
    it { is_expected.to include 'bidding_title' => object.lot.bidding.title }
    it { is_expected.to include 'price_total' => object.price_total.to_s }
    it { is_expected.to include 'current' => proposal.triage? }

    describe 'comment' do
      let!(:change) do
        create(:event_proposal_status_change, from: 'draft', to: proposal.status,
          eventable: proposal, comment: 'Oh noes')
      end

      let(:comment) do
        proposal.event_proposal_status_changes&.changing_to(proposal.status)
          &.last&.comment
      end

      it { is_expected.to include 'comment' => comment }
    end

    describe 'cancel_proposal_refused_comment' do
      let!(:change) do
        create(:event_cancel_proposal_refused, from: 'sent', to: proposal.status,
          eventable: proposal, comment: 'Oh noes')
      end

      let(:comment) do
        proposal.event_cancel_proposal_refuseds&.last&.comment
      end

      it { is_expected.to include 'cancel_proposal_refused_comment' => comment }
    end

    describe 'cancel_proposal_accepted_comment' do
      let!(:change) do
        create(:event_proposal_status_change, from: 'draft', to: proposal.status,
          eventable: proposal, comment: 'Oh noes')
      end

      let(:comment) do
        proposal.event_cancel_proposal_accepteds&.last&.comment
      end

      it { is_expected.to include 'cancel_proposal_accepted_comment' => comment }
    end

    it { expect(subject['provider']['id']).to eq provider.id }
  end

  describe 'associations' do
    describe 'lot' do
      let(:serialized_lot) { format_json(Administrator::LotSerializer, object.lot) }

      it { is_expected.to include 'lot' => serialized_lot }
    end

    describe 'provider' do
      let(:serialized_provider) { format_json(Administrator::ProviderSerializer, object.provider) }

      it { is_expected.to include 'provider' => serialized_provider }
    end

    describe 'lot_group_item_lot_proposals' do
      before { create(:lot_group_item_lot_proposal, lot_proposal: object) }

      let(:serialized_lot_group_item_lot_proposals) do
        object.lot_group_item_lot_proposals.map do |lot_group_item_lot_proposal|
          format_json(Administrator::LotGroupItemLotProposalSerializer, lot_group_item_lot_proposal)
        end
      end

      it { is_expected.to include 'lot_group_item_lot_proposals' => serialized_lot_group_item_lot_proposals }
    end
  end

end
