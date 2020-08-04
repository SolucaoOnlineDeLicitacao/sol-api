require 'rails_helper'

RSpec.describe RecalculateQuantityService do
  let(:bidding)     { create(:bidding, status: :ongoing) }
  let(:covenant)    { bidding.covenant }
  let!(:group_item) { create(:group_item, quantity: group_item_quantity) }
  let(:lot)         { bidding.lots.first }
  let(:another_lot) { create(:lot, bidding: bidding, status: :canceled) }
  let!(:lot_group_item) do
    create(:lot_group_item, group_item: group_item, lot: lot, quantity: lot_group_item_quantity)
  end
  let!(:another_lot_group_item) do
    create(:lot_group_item, group_item: group_item, lot: another_lot, quantity: another_lot_group_item_quantity)
  end
  let(:params)                          { { covenant: covenant } }
  let(:group_item_quantity)             { 200.5 }
  let(:lot_group_item_quantity)         { 100 }
  let(:another_lot_group_item_quantity) { 50 }
  let(:expected)                        { 100.5 }

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.covenant).to eq covenant }
  end

  describe '.call!' do
    subject { described_class.call!(params) }

    context 'when success' do
      context 'and the bidding status is ongoing' do

        context 'and the bidding does not have contracts' do
          it { is_expected.to be_truthy }
          it do
            expect { subject }.
              to change { group_item.reload.available_quantity }.
              from(group_item_quantity).to(expected)
          end
        end

        context 'and the bidding has contracts' do
          let(:user)     { create(:user) }
          let(:proposal) { create(:proposal, bidding: bidding) }
          let!(:contract) do
            create(:contract, status: :partial_execution, proposal: proposal,
                              user: user, user_signed_at: DateTime.current)
          end

          it { is_expected.to be_truthy }
          it do
            expect { subject }.
              to change { group_item.reload.available_quantity }.
              from(group_item_quantity).to(expected)
          end
        end
      end

      context 'and the bidding status is canceled' do
        let(:bidding) { create(:bidding, status: :canceled) }

        context 'and the bidding does not have contracts' do
          it { is_expected.to be_truthy }
          it do
            expect { subject }.
              to change { group_item.reload.available_quantity }.
              from(group_item_quantity).to(expected)
          end
        end

        context 'and the bidding has contracts' do
          let(:user)     { create(:user) }
          let(:proposal) { create(:proposal, bidding: bidding) }
          let!(:contract) do
            create(:contract, status: :partial_execution, proposal: proposal,
                              user: user, user_signed_at: DateTime.current)
          end

          it { is_expected.to be_truthy }
          it do
            expect { subject }.
              to change { group_item.reload.available_quantity }.
              from(group_item_quantity).to(expected)
          end
        end
      end

      context 'and has only one item with returned quantity' do
        let(:proposal) { create(:proposal, bidding: bidding) }
        let(:contract) { create(:contract, proposal: proposal) }
        let!(:returned_lot_group_item) do
          create(:returned_lot_group_item, contract: contract,
                 lot_group_item: lot_group_item,
                 quantity: returned_lot_group_item_quantity)
        end
        let(:group_item_quantity)              { 1 }
        let(:available_quantity)               { 1 }
        let(:lot_group_item_quantity)          { 2 }
        let(:returned_lot_group_item_quantity) { 1 }
        let(:expected)                         { 0 }

        before do
          bidding.lot_group_items.select{ |l| l.id != lot_group_item.id }.each(&:destroy!)
          group_item.update_column(:available_quantity, available_quantity)
          bidding.reload
        end

        it { is_expected.to be_truthy }
        it do
          expect { subject }.
            to change { group_item.reload.available_quantity }.
            from(group_item_quantity).to(expected)
        end
      end

      context 'and the lot_group_item is destroyed' do
        let(:proposal) { create(:proposal, bidding: bidding) }
        let(:contract) { create(:contract, proposal: proposal) }
        let!(:returned_lot_group_item) do
          create(:returned_lot_group_item, contract: contract,
                 lot_group_item: lot_group_item,
                 quantity: returned_lot_group_item_quantity)
        end
        let(:group_item_quantity)              { 10 }
        let(:available_quantity)               { 5 }
        let(:lot_group_item_quantity)          { 5 }
        let(:returned_lot_group_item_quantity) { 1 }

        before do
          bidding.lot_group_items.select{ |l| l.id != lot_group_item.id }.each(&:destroy!)
          group_item.update_column(:available_quantity, available_quantity)
          bidding.reload
          lot_group_item.destroy!
        end

        it { is_expected.to be_truthy }
        it { expect(group_item.reload.available_quantity).to eq (group_item_quantity) }
      end
    end

    context 'when failure' do
      before { group_item.update_column(:quantity, -1) }

      it { expect{ subject }.to raise_exception RecalculateItemError }
    end
  end
end
