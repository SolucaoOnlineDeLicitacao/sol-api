require 'rails_helper'

RSpec.describe GroupItem, type: :model do
  let(:group_item) { build(:group_item) }

  describe 'associations' do
    it { is_expected.to belong_to(:group).counter_cache(true) }
    it { is_expected.to belong_to :item }
    it { is_expected.to have_many(:lot_group_items).dependent(:restrict_with_error) }
    it { is_expected.to have_one(:classification).through(:item).source(:classification) }
    it { is_expected.to have_one(:unit).through(:item).source(:unit) }
    it { is_expected.to have_many(:proposals).through(:lot_group_items).source(:proposals) }
    it { is_expected.to have_many(:accepted_lot_group_item_lot_proposals).through(:proposals).source(:lot_group_item_lot_proposals) }
  end

  describe 'validations' do
    context 'uniqueness' do
      # skips ForeignKeyViolation error - validate_uniqueness_of uses id 0 for uniqueness test
      before { create(:item, id: 0) }

      it { is_expected.to validate_uniqueness_of(:item_id).scoped_to(:group_id) }
    end

    context 'numericality' do
      subject { group_item }

      describe 'quantity' do
        context 'when nil' do
          let(:group_item) { build(:group_item, quantity: nil) }

          before { group_item.valid? }

          it { is_expected.to include_error_key_for(:quantity, :greater_than) }
        end

        context 'when < 0' do
          let(:group_item) { build(:group_item, quantity: -0.01) }

          before { group_item.valid? }

          it { is_expected.to include_error_key_for(:quantity, :greater_than) }
        end

        context 'when = 0.0' do
          let(:group_item) { build(:group_item, quantity: 0.00) }

          before { group_item.valid? }

          it { is_expected.to include_error_key_for(:quantity, :greater_than) }
        end

        context 'when = 0.001' do
          let(:group_item) { build(:group_item, quantity: 0.001) }

          before { group_item.valid? }

          it { is_expected.to include_error_key_for(:quantity, :greater_than) }
        end

        context 'when > 0' do
          let(:group_item) { build(:group_item, quantity: 0.01) }

          before { group_item.valid? }

          it { is_expected.not_to include_error_key_for(:quantity, :greater_than) }
        end
      end

      describe 'available_quantity' do
        let(:group_item) { create(:group_item, available_quantity: 10) }

        context 'when < 0' do
          before do
            group_item.save
            group_item.update_column(:available_quantity, -0.1)
            group_item.valid?
          end

          it { is_expected.to include_error_key_for(:available_quantity, :greater_than_or_equal_to) }
        end

        context 'when = 0' do
          before do
            group_item.save
            group_item.update_column(:available_quantity, 0.00)
            group_item.valid?
          end

          it { is_expected.not_to include_error_key_for(:available_quantity, :greater_than_or_equal_to) }
        end

        context 'when > 0' do
          before { group_item.valid? }

          it { is_expected.not_to include_error_key_for(:available_quantity, :greater_than_or_equal_to) }
        end
      end

      describe 'estimated_cost' do
        context 'when < 0' do
          let(:group_item) { build(:group_item, estimated_cost: -1) }

          before { group_item.valid? }

          it { is_expected.to include_error_key_for(:estimated_cost, :greater_than) }
        end

        context 'when = 0' do
          let(:group_item) { build(:group_item, estimated_cost: 0) }

          before { group_item.valid? }

          it { is_expected.to include_error_key_for(:estimated_cost, :greater_than) }
        end

        context 'when > 0' do
          let(:group_item) { build(:group_item, estimated_cost: 1) }

          before { group_item.valid? }

          it { is_expected.not_to include_error_key_for(:estimated_cost, :greater_than) }
        end
      end
    end
  end

  describe 'callbacks' do
    describe 'before_validation' do
      describe 'ensure_estimated_cost' do
        before { group_item.estimated_cost = '10,05'; group_item.valid? }

        it { expect(group_item.estimated_cost).to eq 10.05 }
      end

      describe 'ensure_quantity' do
        before { group_item.quantity = '10,05'; group_item.valid? }

        it { expect(group_item.quantity).to eq 10.05 }
      end

      describe 'ensure_available_quantity' do
        let(:group_item) { build(:group_item, quantity: 100, available_quantity: 50) }

        before { group_item.valid? }

        it { expect(group_item.available_quantity).to eq 100 }
      end
    end
  end

  describe 'sortable' do
    it { expect(described_class.default_sort_column).to eq 'items.title' }
    it { expect(described_class.sort_associations).to eq :item }
  end

  describe 'methods' do
    describe 'text' do
      it { expect(group_item.text).to eq group_item.item.text }
    end
  end

  describe 'behaviors' do
    it { is_expected.to be_versionable }
  end
end
