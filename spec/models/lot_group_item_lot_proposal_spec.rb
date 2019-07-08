require 'rails_helper'

RSpec.describe LotGroupItemLotProposal, type: :model do
  describe 'factory' do
    let(:factory) { build(:lot_group_item_lot_proposal) }

    subject { factory }

    it { is_expected.to be_valid }
  end

  describe 'associations' do
    it { is_expected.to belong_to :lot_group_item }
    it { is_expected.to belong_to(:lot_proposal).touch(true) }

    it { is_expected.to have_one(:group_item).through(:lot_group_item) }
    it { is_expected.to have_one(:item).through(:group_item) }
    it { is_expected.to have_one(:provider).through(:lot_proposal) }
    it { is_expected.to have_one(:proposal).through(:lot_proposal) }
    it { is_expected.to have_one(:bidding).through(:proposal) }
    it { is_expected.to have_one(:classification).through(:group_item).source(:classification) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :lot_group_item }
    it { is_expected.to validate_presence_of :lot_proposal }

    context 'uniqueness' do
      before { create(:lot_group_item, id: 0) }

      it { is_expected.to validate_uniqueness_of(:lot_group_item_id).scoped_to(:lot_proposal_id) }
    end

    context 'numericality' do
      subject { resource.errors.details.dig(:price, 0, :error) }

      context 'when 0' do
        let(:resource) { build(:lot_group_item_lot_proposal, price: 0) }

        before { resource.valid? }

        it { is_expected.to eq :greater_than }
      end

      context 'when > 0' do
        let(:resource) { build(:lot_group_item_lot_proposal, price: 0.01) }

        before { resource.valid? }

        it { is_expected.to be_nil }
      end
    end

    context 'when global' do
      describe 'ensure_group_itens_prices' do
        let(:covenant) { create(:covenant) }
        let(:bidding) do
          create(:bidding, kind: :global, status: :draft, build_lot: false,
            covenant: covenant)
        end

        let(:item1) do
          create(:item, title: "Telha metálica trapezoidal",
            description: "Fornecimento de telhas metálica trapezoidal")
        end

        let(:item2) do
          create(:item, title: "Regador de plástico 5 Litros",
            description: "Regador de plástico capacidade 5 Litros")
        end

        let(:group) do
          group = Group.new(covenant: covenant); group.save(validate: false);
          group
        end

        let(:group_item1) { create(:group_item, group: group, item: item1) }
        let(:group_item2) { create(:group_item, group: group, item: item2) }

        let!(:lot1) do
          lot = Lot.new(id: 1, bidding: bidding, name: 'Lote A'); lot.save(validate: false); lot
        end

        let!(:lot2) do
          lot = Lot.new(id: 2, bidding: bidding, name: 'Lote B'); lot.save(validate: false); lot
        end

        let!(:lot_group_item1) do
          create(:lot_group_item, id: 1, lot: lot1, group_item: group_item1)
        end

        let!(:lot_group_item2) do
          create(:lot_group_item, id: 2, lot: lot2, group_item: group_item1)
        end

        let!(:proposal) { create(:proposal, status: :draft, bidding: bidding, build_lot_proposal: false) }
        let!(:proposal2) { create(:proposal, status: :draft, bidding: bidding, build_lot_proposal: false) }

        let(:provider1) { create(:provider, id: 1) }
        let(:provider2) { create(:provider, id: 2) }
        let!(:supplier1) { create(:supplier, provider: provider1) }
        let!(:supplier2) { create(:supplier, provider: provider2) }

        let!(:lot_proposal1) do
          create(:lot_proposal, id: 1, lot: lot1, proposal: proposal, supplier: supplier1)
        end

        let(:lot_proposal2) do
          build(:lot_proposal, id: 2, lot: lot2, proposal: proposal, supplier: supplier1)
        end

        let!(:lot_proposal3) do
          create(:lot_proposal, id: 3, lot: lot1, proposal: proposal2, supplier: supplier2)
        end

        let(:lot_group_item_lot_proposal1) do
          lot_proposal1.lot_group_item_lot_proposals.first
        end

        let(:lot_group_item_lot_proposal2) do
          lot_proposal2.lot_group_item_lot_proposals.first
        end

        let(:lot_group_item_lot_proposal3) do
          lot_proposal3.lot_group_item_lot_proposals.first
        end

        context 'updates prices' do
          before do
            lot_proposal2.save(validate: false)

            lot_group_item_lot_proposal3.price = lot_group_item_lot_proposal1.price+15
            lot_group_item_lot_proposal3.save(validate: false)
            lot_group_item_lot_proposal2.price = lot_group_item_lot_proposal1.price+10
            lot_group_item_lot_proposal2.save(validate: false)

            lot_group_item_lot_proposal1.reload
            lot_group_item_lot_proposal2.reload
          end

          it do
            expect(lot_group_item_lot_proposal1.price)
              .to eq lot_group_item_lot_proposal2.price
          end

          it do
            expect(lot_group_item_lot_proposal1.price)
              .not_to eq lot_group_item_lot_proposal3.price
          end

        end
      end
    end
  end

  describe 'callbacks' do
    describe 'before_validation' do
      describe 'ensure_price' do
        let(:lot_group_item_lot_proposal) { build(:lot_group_item_lot_proposal) }

        before { lot_group_item_lot_proposal.price = '10,05'; lot_group_item_lot_proposal.valid? }

        it { expect(lot_group_item_lot_proposal.price).to eq 10.05 }
      end
    end
  end

  describe 'behaviors' do
    it { is_expected.to be_versionable }
  end
end
