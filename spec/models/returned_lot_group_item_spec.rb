require 'rails_helper'

RSpec.describe ReturnedLotGroupItem, type: :model do

  describe 'associations' do
    it { is_expected.to belong_to(:lot_group_item) }
    it { is_expected.to belong_to(:contract) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :quantity }

    context 'numericality' do
      let(:contract) { create(:contract) }
      let(:lot_group_item) { create(:lot_group_item, quantity: quantity) }
      let(:returned_lot_group_item) do
        build(:returned_lot_group_item, contract: contract,
                                        lot_group_item: lot_group_item,
                                        quantity: returned_quantity)
      end

      subject { returned_lot_group_item.valid? }

      context 'when quantity is less than the returned_quantity' do
        let(:quantity)          { 50 }
        let(:returned_quantity) { 20 }

        it { is_expected.to be_truthy }
      end

      context 'when quantity is greater or equal than the returned_quantity' do
        let(:quantity)          { 20 }
        let(:returned_quantity) { 50 }

        it { is_expected.to be_falsey }
      end

      context 'when quantity is less than zero' do
        let(:quantity)          { 20 }
        let(:returned_quantity) { -1 }

        it { is_expected.to be_falsey }
      end

      context 'when quantity is equal zero' do
        let(:quantity)          { 20 }
        let(:returned_quantity) { 0 }

        it { is_expected.to be_truthy }
      end
    end
  end

  describe 'behaviors' do
    it { is_expected.to be_versionable }
  end
end
