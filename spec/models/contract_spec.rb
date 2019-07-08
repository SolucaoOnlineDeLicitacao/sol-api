require 'rails_helper'

RSpec.describe Contract, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to :proposal }
    it { is_expected.to belong_to(:supplier).optional }
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to(:document).optional }

    it { is_expected.to have_one(:bidding).through(:proposal) }
    it { is_expected.to have_one(:classification).through(:bidding) }

    it { is_expected.to have_many(:returned_lot_group_items).dependent(:destroy) }
    it { is_expected.to have_many(:lot_group_items).through(:lot_group_item_lot_proposals) }
    it { is_expected.to have_many(:lot_group_item_lot_proposals).through(:proposal) }
    it { is_expected.to have_many(:lot_group_items_returned).through(:returned_lot_group_items) }
    it { is_expected.to have_many(:event_contract_refuseds).class_name(Events::ContractRefused).dependent(:destroy) }
  end

  describe 'setup' do
    describe 'default status' do
      let(:contract) { create :contract }
      it { expect(contract.waiting_signature?).to be_truthy }
    end

    describe 'default_scope' do
      let!(:contract) { create(:contract) }
      let!(:deleted_contract) { create(:contract, deleted_at: DateTime.current) }

      it { expect(Contract.all).to eq [contract] }
    end
  end

  describe 'callbacks' do
    describe 'after_create' do
      let!(:contract) { create(:contract) }

      describe 'update_title' do
        let(:expected_title) { "#{contract.id}/#{contract.created_at.year}" }

        it { expect(contract.title).to eq expected_title }
      end
    end
  end

  describe 'scopes' do
    describe 'waiting_signature_and_old' do
      let(:supplier) { create(:supplier) }
      let!(:eligible_contract) do
        create(:contract, status: :waiting_signature, created_at: 5.days.ago, supplier: nil)
      end
      let!(:not_eligible_contract_1) do
        create(:contract, status: :signed, created_at: 5.days.ago, supplier: nil)
      end
      let!(:not_eligible_contract_2) do
        create(:contract, status: :waiting_signature, created_at: 4.days.ago, supplier: nil)
      end
      let!(:not_eligible_contract_3) do
        create(:contract, status: :waiting_signature, created_at: 5.days.ago,
                          supplier: supplier, supplier_signed_at: Date.current)
      end
      let!(:not_eligible_contract_4) do
        create(:contract, status: :waiting_signature, created_at: 5.days.ago, supplier: nil)
      end

      before do
        not_eligible_contract_4.proposal = nil
        not_eligible_contract_4.save!(validate: false)
      end

      subject { Contract.waiting_signature_and_old }

      it { is_expected.to match_array [eligible_contract] }
    end
  end

  describe 'validations' do
    describe 'deadline field' do
      it { is_expected.to validate_presence_of :deadline }
    end

    describe 'supplier association' do
      let!(:supplier) { create(:supplier) }

      context 'when supplier_signed_at' do
        let(:contract) { build(:contract, supplier: supplier, supplier_signed_at: DateTime.current) }

        it { expect(contract.valid?).to be_truthy }
        it { expect(contract.supplier).to be_present }
      end

      context 'when not supplier_signed_at' do
        let(:contract) { build(:contract, supplier: supplier) }

        it { expect(contract.valid?).to be_falsy }
      end
    end
  end

  describe 'nesteds' do
    it { is_expected.to accept_nested_attributes_for :returned_lot_group_items }
  end

  describe 'delegations' do
    it { is_expected.to delegate_method(:price_total).to(:proposal).with_prefix }
  end

  describe 'sortable' do
    it { expect(described_class.default_sort_column).to eq 'contracts.id' }
    it { expect(described_class.default_sort_direction).to eq :desc }
  end

  describe 'methods' do
    context '.classification_name' do
      let(:user) { create(:user) }
      let(:classification) { create(:classification, name: 'BENS') }
      let(:bidding) { create(:bidding, classification: classification) }
      let(:proposal) { create(:proposal, bidding: bidding) }
      let(:contract) { create(:contract, proposal: proposal, user: user) }

      it { expect(contract.classification_name).to eq classification.name }
    end

    describe '.refused_by!' do
      let(:user) { create(:user) }
      let!(:provider) { create(:provider) }
      let!(:bidding) { create(:bidding, status: :finnished, kind: :global) }
      let!(:proposal) { create(:proposal, bidding: bidding, provider: provider, status: :accepted) }

      before { contract.refused_by!(user_refused) }

      context 'by supplier' do
        let!(:supplier) { create(:supplier, provider: provider) }
        let!(:contract) do
          create(:contract, proposal: proposal,
            user: user, user_signed_at: DateTime.current,
            supplier: supplier, supplier_signed_at: DateTime.current
          )
        end
        let(:user_refused) { supplier }

        it { expect(contract.refused?).to be_truthy }
        it { expect(contract.refused_by).to eq supplier }
        it { expect(contract.refused_by_type).to eq 'Supplier' }
        it { expect(contract.refused_by_at).to be_kind_of ActiveSupport::TimeWithZone }
      end

      context 'by system' do
        let!(:contract) { create(:contract, proposal: proposal) }
        let(:user_refused) { create(:system) }

        it { expect(contract.refused?).to be_truthy }
        it { expect(contract.refused_by_id).to eq user_refused.id }
        it { expect(contract.refused_by_type).to eq user_refused.class.to_s }
        it { expect(contract.refused_by_at).to be_kind_of ActiveSupport::TimeWithZone }
      end
    end

    describe '.all_signed?' do
      context 'when all signed' do
        let(:user) { create(:user) }
        let!(:provider) { create(:provider) }
        let!(:supplier) { create(:supplier, provider: provider) }
        let!(:bidding) { create(:bidding, status: :finnished, kind: :global) }
        let!(:proposal) { create(:proposal, bidding: bidding, provider: provider, status: :accepted) }
        let!(:contract) do
          create(:contract, proposal: proposal,
            user: user, user_signed_at: DateTime.current,
            supplier: supplier, supplier_signed_at: DateTime.current
          )
        end

        it { expect(contract.all_signed?).to be_truthy }
      end

      context 'when not all signed' do
        let(:user) { create(:user) }
        let!(:provider) { create(:provider) }
        let!(:supplier) { create(:supplier, provider: provider) }
        let!(:bidding) { create(:bidding, status: :finnished, kind: :global) }
        let!(:proposal) { create(:proposal, bidding: bidding, provider: provider, status: :accepted) }
        let!(:contract) do
          create(:contract, proposal: proposal,
            user: user, user_signed_at: DateTime.current
          )
        end

        it { expect(contract.all_signed?).to be_falsy }
      end
    end

    describe '.not_refused' do
      let!(:refused_contract) { create(:contract, status: :refused) }
      let!(:another_contract) do
        create(:contract, proposal: refused_contract.proposal,
          user: refused_contract.user, status: :completed)
      end

      it { expect(Contract.not_refused).to match_array [another_contract] }
    end

    describe '.by_classification' do
      let!(:classification_1) { create(:classification, name: 'BENS') }
      let!(:classification_2) { create(:classification, name: 'OBRAS') }
      let!(:classification_3) { create(:classification, name: 'SERVIÇOS') }
      let!(:classification_4) do
        create(:classification, name: 'BENS 2', classification_id: classification_3.id)
      end
      let(:user) { create(:user) }

      let!(:providers) { create_list(:provider, 2, :skip_validation, skip_classification: true) }
      let!(:provider) { providers.first }
      let!(:supplier) { create(:supplier, provider: provider) }

      let!(:item_1) { create(:item, classification: classification_1) }
      let!(:item_2) { create(:item, classification: classification_2) }
      let!(:item_3) { create(:item, classification: classification_3) }
      let!(:item_4) { create(:item, classification: classification_1) }

      let!(:covenant) { create(:covenant, group: false) }

      let!(:group_1) do
        create(:group, :skip_validation, build_group_itens: false, covenant: covenant)
      end

      let!(:group_2) do
        create(:group, :skip_validation, build_group_itens: false, covenant: covenant)
      end

      let!(:group_3) do
        create(:group, :skip_validation, build_group_itens: false, covenant: covenant)
      end

      let!(:group_item_1) { create(:group_item, group: group_1, item: item_1) }
      let!(:group_item_2) { create(:group_item, group: group_2, item: item_2) }
      let!(:group_item_3) { create(:group_item, group: group_3, item: item_3) }
      let!(:group_item_4) { create(:group_item, group: group_3, item: item_4) }

      let!(:bidding_1) do
        create(:bidding, build_lot: false, covenant: covenant, status: :draft,
          classification: classification_1, kind: 1)
      end

      let!(:bidding_2) do
        create(:bidding, build_lot: false, covenant: covenant, status: :draft,
          classification: classification_2, kind: 2)
      end

      let!(:bidding_3) do
        create(:bidding, build_lot: false, covenant: covenant, status: :draft,
          classification: classification_3, kind: :global)
      end

      let!(:bidding_4) do
        create(:bidding, build_lot: false, covenant: covenant, status: :draft,
          classification: classification_1, kind: :global)
      end

      let!(:lot_1) do
        create(:lot, :skip_validation, bidding: bidding_1,
            build_lot_group_item: false)
      end

      let!(:lot_2) do
        create(:lot, :skip_validation, bidding: bidding_2,
            build_lot_group_item: false)
      end

      let!(:lot_3) do
        create(:lot, :skip_validation, bidding: bidding_3,
            build_lot_group_item: false)
      end

      let!(:lot_4) do
        create(:lot, :skip_validation, bidding: bidding_4,
            build_lot_group_item: false)
      end

      let!(:lot_group_item_1) do
        create(:lot_group_item, group_item: group_item_1, lot: lot_1)
      end

      let!(:lot_group_item_2) do
        create(:lot_group_item, group_item: group_item_2, lot: lot_2)
      end

      let!(:lot_group_item_3) do
        create(:lot_group_item, group_item: group_item_3, lot: lot_3)
      end

      let!(:lot_group_item_4) do
        create(:lot_group_item, group_item: group_item_4, lot: lot_4)
      end

      let!(:proposal_1) do
        create(:proposal, build_lot_proposal: false, bidding: bidding_1,
            provider: provider)
      end

      let!(:proposal_2) do
        create(:proposal, build_lot_proposal: false, bidding: bidding_2,
            provider: provider)
      end

      let!(:proposal_3) do
        create(:proposal, build_lot_proposal: false, bidding: bidding_3,
            provider: provider)
      end

      let!(:proposal_4) do
        create(:proposal, build_lot_proposal: false, bidding: bidding_4,
            provider: provider)
      end

      let!(:lot_proposal_1) do
        create(:lot_proposal, build_lot_group_item_lot_proposal: false,
            lot: lot_1, proposal: proposal_1, supplier: supplier)
      end

      let!(:lot_proposal_2) do
        create(:lot_proposal, build_lot_group_item_lot_proposal: false,
            lot: lot_2, proposal: proposal_2, supplier: supplier)
      end

      let!(:lot_proposal_3) do
        create(:lot_proposal, build_lot_group_item_lot_proposal: false,
            lot: lot_3, proposal: proposal_3, supplier: supplier)
      end

      let!(:lot_proposal_4) do
        create(:lot_proposal, build_lot_group_item_lot_proposal: false,
            lot: lot_4, proposal: proposal_4, supplier: supplier)
      end

      let!(:lot_group_item_lot_proposal_1) do
        create(:lot_group_item_lot_proposal, lot_proposal: lot_proposal_1,
            lot_group_item: lot_group_item_1)
      end

      let!(:lot_group_item_lot_proposal_2) do
        create(:lot_group_item_lot_proposal, lot_proposal: lot_proposal_2,
            lot_group_item: lot_group_item_2)
      end

      let!(:lot_group_item_lot_proposal_3) do
        create(:lot_group_item_lot_proposal, lot_proposal: lot_proposal_3,
            lot_group_item: lot_group_item_3)
      end

      let!(:lot_group_item_lot_proposal_4) do
        create(:lot_group_item_lot_proposal, lot_proposal: lot_proposal_4,
            lot_group_item: lot_group_item_4)
      end

      let!(:contract_1) { create(:contract, proposal: proposal_1, user: user) }
      let!(:contract_2) { create(:contract, proposal: proposal_2, user: user) }
      let!(:contract_3) { create(:contract, proposal: proposal_3, user: user) }
      let!(:contract_4) { create(:contract, proposal: proposal_4, user: user) }

      before { proposal_2.accepted!; proposal_3.accepted! }

      let(:classification_ids) do
        [ classification_1.id, classification_2.id, classification_3.id,classification_4.id ]
      end

      it { expect(Contract.by_classification(classification_ids)).to match_array [contract_2, contract_3] }

    end

    describe '.price_by_proposal_accepted' do

      let!(:bidding_1) { create(:bidding, status: :draft, kind: 1) }

      let!(:bidding_2) { create(:bidding, status: :draft, kind: 2) }

      let!(:bidding_3) { create(:bidding, status: :draft, kind: :global) }

      let!(:bidding_4) { create(:bidding, status: :draft, kind: :global) }

      let!(:proposal_1) do
        proposal = create(:proposal, bidding: bidding_1)
        proposal.update_column(:price_total, 1)
        proposal
      end

      let!(:proposal_2) do
        proposal = create(:proposal, bidding: bidding_2)

        proposal.update_column(:price_total, 2)
        proposal
      end

      let!(:proposal_3) do
        proposal = create(:proposal, bidding: bidding_3)
        proposal.update_column(:price_total, 3)
        proposal
      end

      let!(:proposal_4) do
        proposal = create(:proposal, bidding: bidding_4)
        proposal.update_column(:price_total, 4)
        proposal
      end

      let!(:contract_1) { create(:contract, proposal: proposal_1) }
      let!(:contract_2) { create(:contract, proposal: proposal_2) }
      let!(:contract_3) { create(:contract, proposal: proposal_3) }
      let!(:contract_4) { create(:contract, proposal: proposal_4) }

      before { proposal_2.accepted!; proposal_3.accepted! }

      let(:sum_prices) { proposal_2.price_total + proposal_3.price_total }

      it { expect(contract_3.price_by_proposal_accepted).to eq proposal_3.price_total }
      it { expect(contract_4.price_by_proposal_accepted).to eq 0.0 }

    end
  end

  describe 'behaviors' do
    it { is_expected.to be_versionable }
  end
end
