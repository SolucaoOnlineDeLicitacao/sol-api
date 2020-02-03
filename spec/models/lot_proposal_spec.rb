require 'rails_helper'

RSpec.describe LotProposal, type: :model do
  describe 'factory' do
    let(:factory) { build(:lot_proposal) }

    subject { factory }

    it { is_expected.to be_valid }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:lot).counter_cache(true) }
    it { is_expected.to belong_to :proposal }
    it { is_expected.to belong_to :supplier }

    it { is_expected.to have_one(:provider).through(:supplier) }

    it { is_expected.to have_many(:lot_group_item_lot_proposals).dependent(:destroy) }
    it { is_expected.to have_many(:lot_group_items).through(:lot) }
    it { is_expected.to have_many(:group_items).through(:lot_group_items) }
  end

  describe 'validations' do
    it_behaves_like "bidding_modality_validations"

    it { is_expected.to validate_presence_of :lot }
    it { is_expected.to validate_presence_of :proposal }
    it { is_expected.to validate_presence_of :supplier }
    
    context 'uniqueness' do
      before { build(:lot_proposal) }

      it { is_expected.to validate_uniqueness_of(:lot_id).scoped_to(:supplier_id) }
    end

    describe 'delivery_price' do
      let(:lot_proposal) { create(:lot_proposal, delivery_price: 10) }

      subject { lot_proposal }

      context 'when < 0' do
        before do
          lot_proposal.save
          lot_proposal.update_column(:delivery_price, -10)
          lot_proposal.valid?
        end

        it { is_expected.to include_error_key_for(:delivery_price, :greater_than_or_equal_to) }
      end

      context 'when = 0' do
        before do
          lot_proposal.save
          lot_proposal.update_column(:delivery_price, 0)
          lot_proposal.valid?
        end

        it { is_expected.not_to include_error_key_for(:delivery_price, :greater_than_or_equal_to) }
      end

      context 'when > 0' do
        before { lot_proposal.valid? }

        it { is_expected.not_to include_error_key_for(:delivery_price, :greater_than_or_equal_to) }
      end
    end

    describe 'validate_price_total' do
      with_versioning do
        let(:proposal) { create(:proposal, status: proposal_status) }
        let(:lot_proposal) { build(:lot_proposal, proposal: proposal, price_total: 100) }

        before do
          allow_any_instance_of(described_class).
            to receive(:recalculated_total).and_return(recalculated_total)
        end

        subject { lot_proposal.save }

        context 'when recalculated_total > price_total' do
          let(:recalculated_total) { 200 }

          context 'and proposal is draw' do
            let(:proposal_status) { :draw }

            before { subject }

            it { expect(lot_proposal.errors).to include :price_total }
          end

          context 'and proposal was draw' do
            let(:proposal_status) { :draw }

            before do
              proposal.accepted!
              subject
            end

            it { expect(lot_proposal.errors).to include :price_total }
          end

          context 'and proposal is not and was not draw' do
            let(:proposal_status) { :accepted }

            before { subject }

            it { is_expected.to be_truthy }
          end
        end

        context 'when recalculated_total <= price_total' do
          let(:recalculated_total) { 90 }

          context 'and proposal is draw' do
            let(:proposal_status) { :draw }

            before { subject }

            it { is_expected.to be_truthy }
          end

          context 'and proposal was draw' do
            let(:proposal_status) { :draw }

            before do
              proposal.accepted!
              subject
            end

            it { is_expected.to be_truthy }
          end

          context 'and proposal is not and was not draw' do
            let(:proposal_status) { :accepted }

            before { subject }

            it { is_expected.to be_truthy }
          end
        end
      end
    end
  end

  describe 'nested' do
    it { is_expected.to accept_nested_attributes_for(:lot_group_item_lot_proposals).allow_destroy(true) }
  end

  describe 'delegations' do
    it { is_expected.to delegate_method(:status).to(:proposal).with_prefix }
  end

  describe 'sortable' do
    it { expect(described_class.default_sort_column).to eq 'lot_proposals.price_total' }
  end

  describe 'methods' do
    describe '#status' do
      let(:lot_proposal) { build(:lot_proposal) }
      it { expect(lot_proposal.status).to eq lot_proposal.proposal_status }
    end

    describe '.search' do
      it { expect(LotProposal.search).to eq LotProposal.all }
    end

    describe 'sort' do
      let(:bidding) { create(:bidding, status: 1) }
      let(:lot) { bidding.lots.first }

      let!(:lot_proposal) { create(:lot_proposal, lot: lot) }

      let!(:lot_proposal_2) { create(:lot_proposal, lot: lot) }
      let!(:proposal_2) { lot_proposal_2.proposal }

      let!(:lot_proposal_3) { create(:lot_proposal, lot: lot) }
      let!(:proposal_3) { lot_proposal_3.proposal }

      before do
        lot_proposal.update_column(:price_total, 0.5)

        lot_proposal_2.update_column(:price_total, 0.2)
        proposal_2.update_column(:sent_updated_at, DateTime.now+1.hour)

        lot_proposal_3.update_column(:price_total, 0.2)
        proposal_3.update_column(:sent_updated_at, DateTime.now)
      end

      describe '.lower' do
        it { expect(LotProposal.lower).to eq lot_proposal_3 }
      end

      describe 'all_lower' do
        it { expect(LotProposal.all_lower[0..2]).to eq [lot_proposal_3, lot_proposal_2, lot_proposal] }
      end
    end
  end

  describe 'callbacks' do
    describe 'update_price_total' do
      subject { resource.save }

      context 'when not proposal draw' do
        let!(:resource) { create(:lot_proposal, delivery_price: 100) }
        let(:lot_group_item_lot_proposal) { resource.lot_group_item_lot_proposals.first }
        let(:lot_group_item) { lot_group_item_lot_proposal.lot_group_item }

        before do
          lot_group_item_lot_proposal.price = 1_300
          lot_group_item.quantity = 10

          lot_group_item.save
          lot_group_item_lot_proposal.save

          subject
        end

        it { expect(resource.price_total.to_d).to eq 13_100.to_d }
      end

      context 'when proposal draw' do
        let!(:resource) { create(:lot_proposal, delivery_price: 100) }
        let!(:proposal) { resource.proposal }
        let!(:lot_group_item_lot_proposal) { resource.lot_group_item_lot_proposals.first }
        let!(:lot_group_item) { lot_group_item_lot_proposal.lot_group_item }

        context 'when bidding' do
          let!(:bidding) { proposal.bidding }

          before do
            proposal.draw!

            lot_group_item_lot_proposal.price = 1_300
            lot_group_item.quantity = 10

            lot_group_item.save
            lot_group_item_lot_proposal.save
          end

          context 'is draw' do
            before do
              bidding.draw!

              resource.update_column(:price_total, 300)
            end

            it { expect(resource.price_total.to_d).not_to eq 13_100.to_d }
          end

          context 'is ongoing' do
            before do
              bidding.ongoing!

              resource.update_column(:price_total, 300)
            end

            it { expect(resource.price_total.to_d).not_to eq 13_100.to_d }
          end
        end

        context 'when price > price_total' do
          before do
            proposal.draw!

            lot_group_item_lot_proposal.price = 1_300
            lot_group_item.quantity = 10

            lot_group_item.save
            lot_group_item_lot_proposal.save

            resource.update_column(:price_total, 300)
          end

          it { expect(resource.price_total.to_d).not_to eq 13_100.to_d }
        end

        context 'when price <= price_total' do
          before do
            proposal.draw!

            lot_group_item_lot_proposal.price = 1_200
            lot_group_item.quantity = 10

            lot_group_item.save
            lot_group_item_lot_proposal.save

            resource.update_column(:price_total, 23000)

            subject
          end

          it { expect(resource.price_total.to_d).to eq 12_100.to_d }
        end
      end
    end

    describe 'before_validation' do
      describe 'ensure_delivery_price' do
        let(:lot_proposal) { build(:lot_proposal) }

        before { lot_proposal.delivery_price = '10,05'; lot_proposal.valid? }

        it { expect(lot_proposal.delivery_price).to eq 10.05 }
      end
    end
  end

  context 'when trying to update lot_proposal in a bidding that is drawed and global' do
    let(:covenant) { create(:covenant) }
    let(:group) { covenant.groups.first }
    let(:admin) { create(:admin) }

    let(:item_2) { create(:item, title: 'Cimento', description: 'Cimento fino', owner: admin) }

    let(:group_item_1) { covenant.group_items.first }
    let(:group_item_2) { create(:group_item, group: group, item: item_2) }

    # generic attributes
    let(:lot_base) { { build_lot_group_item: false, status: :accepted } }
    let(:proposal_status) { { status: :draw } }
    let(:proposal_base) { proposal_status.merge(bidding: bidding) }

    # lot
    let(:lot_group_item_1) { create(:lot_group_item, group_item: group_item_1) }
    let(:lot_group_item_2) { create(:lot_group_item, group_item: group_item_2) }

    let(:lot) do
      create(:lot, lot_base.merge(lot_group_items: [lot_group_item_1, lot_group_item_2]))
    end

    let(:proposal) { create(:proposal, proposal_base) }
    let(:lot_group_item_lot_proposal_1) do
      create(:lot_group_item_lot_proposal, lot_group_item: lot_group_item_1, price: 1)
    end
    let(:lot_group_item_lot_proposal_2) do
      create(:lot_group_item_lot_proposal, lot_group_item: lot_group_item_2, price: 1)
    end
    let!(:lot_proposal) do
      create(:lot_proposal, build_lot_group_item_lot_proposal: false, lot: lot, proposal: proposal,
                            delivery_price: 10,
                            lot_group_item_lot_proposals: [
                              lot_group_item_lot_proposal_1,
                              lot_group_item_lot_proposal_2
                            ])
    end

    # bidding
    let(:bidding) { create(:bidding, build_lot: false, lots: [lot], kind: :global, status: :draw) }

    let(:params) do
      {
        id: lot_proposal.id,
        delivery_price: 10,
        lot_group_item_lot_proposals_attributes: [
          {
            id: lot_group_item_lot_proposal_1.id,
            lot_group_item_id: lot_group_item_1.id,
            price: 0.9,
            _destroy: false
          },
          {
            id: lot_group_item_lot_proposal_2.id,
            lot_group_item_id: lot_group_item_2.id,
            price: 0.9,
            _destroy: false
          }
        ]
      }
    end

    before { subject }

    subject { lot_proposal.update!(params) }

    it { is_expected.to be_truthy }
  end

  describe 'behaviors' do
    it { is_expected.to be_versionable }
  end
end
