require 'rails_helper'

RSpec.describe ReturnedLotGroupItem, type: :model do
  let(:contract) { create(:contract) }
  let(:quantity) { 10 }
  let(:returned_quantity) { 1 }
  let(:lot_group_item) { create(:lot_group_item, quantity: quantity) }
  let(:returned_lot_group_item) do
    build(:returned_lot_group_item, contract: contract,
                                    lot_group_item: lot_group_item,
                                    quantity: returned_quantity)
  end

  describe 'associations' do
    it { is_expected.to belong_to(:lot_group_item) }
    it { is_expected.to belong_to(:contract) }
  end

  describe 'validations' do
    context 'numericality' do
      subject { returned_lot_group_item.valid? }

      context 'when returned_quantity is less than the quantity' do
        let!(:quantity)          { 50 }
        let!(:returned_quantity) { 20.9 }

        it { is_expected.to be_truthy }
      end

      context 'when returned_quantity is greater or equal than the quantity' do
        let!(:quantity)          { 20.5 }
        let!(:returned_quantity) { 50.5 }

        it { is_expected.to be_falsey }
      end

      context 'when returned_quantity is less than zero' do
        let!(:quantity)          { 20 }
        let!(:returned_quantity) { -0.01 }

        it { is_expected.to be_falsey }
      end

      context 'when returned_quantity is equal zero' do
        let!(:quantity)          { 20 }
        let!(:returned_quantity) { 0 }

        it { is_expected.to be_truthy }
      end

      context 'when returned_quantity is nil' do
        let!(:quantity)          { 20 }
        let!(:returned_quantity) { nil }

        it { is_expected.to be_falsey }
      end      
    end
  end

  describe 'callbacks' do
    describe 'ensure_quantity' do
      let!(:quantity) { '10,05' }

      before do
        returned_lot_group_item.quantity = quantity
        returned_lot_group_item.valid?
      end

      it { expect(returned_lot_group_item.quantity).to eq 10.05 }
    end
  end

  describe 'behaviors' do
    it { is_expected.to be_versionable }
  end
end
