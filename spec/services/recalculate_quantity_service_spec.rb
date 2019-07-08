require 'rails_helper'

RSpec.describe RecalculateQuantityService do
  let(:bidding) { create(:bidding, status: :ongoing) }
  let(:covenant) { bidding.covenant }
  let!(:group_item) { create(:group_item, quantity: group_item_quantity) }
  let(:lot) { bidding.lots.first }
  let(:another_lot) { create(:lot, bidding: bidding, status: :canceled) }
  let!(:lot_group_item) do
    create(:lot_group_item, group_item: group_item, lot: lot, quantity: 100)
  end
  let!(:another_lot_group_item) do
    create(:lot_group_item, group_item: group_item, lot: another_lot, quantity: 50)
  end
  let(:group_item_quantity) { 200 }
  let(:params) { { covenant: covenant } }
  let(:expected) { 100 }

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
          let(:user) { create(:user) }
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
          let(:user) { create(:user) }
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
    end

    context 'when failure' do
      before { group_item.update_column(:quantity, -1) }

      it { expect{ subject }.to raise_exception RecalculateItemError }
    end
  end
end
