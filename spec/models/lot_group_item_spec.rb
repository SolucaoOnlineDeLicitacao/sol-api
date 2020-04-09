require 'rails_helper'

RSpec.describe LotGroupItem, type: :model do
  let(:lot_group_item) { build(:lot_group_item) }

  describe 'associations' do
    it { is_expected.to belong_to(:lot).counter_cache(true) }
    it { is_expected.to belong_to(:group_item) }
    it { is_expected.to have_many(:lot_group_item_lot_proposals).dependent(:destroy) }
    it { is_expected.to have_one(:bidding).through(:lot) }
    it { is_expected.to have_one(:item).through(:group_item) }
    it { is_expected.to have_one(:classification).through(:group_item).source(:classification) }
    it { is_expected.to have_many(:proposals).through(:lot_group_item_lot_proposals).source(:proposal) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :lot }
    it { is_expected.to validate_presence_of :group_item }

    context 'uniqueness' do
      # skips ForeignKeyViolation error - validate_uniqueness_of uses id 0 for uniqueness test
      before { create(:group_item, id: 0) }

      it { is_expected.to validate_uniqueness_of(:group_item_id).scoped_to(:lot_id) }
    end

    context 'numericality' do
      describe 'quantity' do
        subject { lot_group_item.errors.details.dig(:quantity, 0, :error) }

        context 'when nil' do
          let(:lot_group_item) { build(:lot_group_item, quantity: nil) }

          before { lot_group_item.valid? }

          it { is_expected.to eq :greater_than }
        end

        context 'when < 0' do
          let(:lot_group_item) { build(:lot_group_item, quantity: -0.1) }

          before { lot_group_item.valid? }

          it { is_expected.to eq :greater_than }
        end

        context 'when = 0' do
          let(:lot_group_item) { build(:lot_group_item, quantity: 0.00) }

          before { lot_group_item.valid? }

          it { is_expected.to eq :greater_than }
        end

        context 'when = 0.001' do
          let(:lot_group_item) { build(:lot_group_item, quantity: 0.001) }

          before { lot_group_item.valid? }

          it { is_expected.to eq :greater_than }
        end

        context 'when > 0' do
          let(:lot_group_item) { build(:lot_group_item, quantity: 0.01) }

          before { lot_group_item.valid? }

          it { is_expected.to be_nil }
        end

        context 'when == max_quantity' do
          let(:group_item) { create(:group_item) }
          let(:lot_group_item) { build(:lot_group_item, group_item: group_item, quantity: 2) }

          before do
            group_item.quantity = 3
            group_item.available_quantity = 2
            group_item.save
            lot_group_item.valid?
          end

          it { is_expected.to be_nil }
        end

        context 'when > max_quantity' do
          context 'when draft' do
            let!(:bidding) { create(:bidding, status: :draft) }
            let(:lot) { create(:lot, bidding: bidding) }
            let(:group_item) { create(:group_item) }
            let!(:lot_group_item) do
              build(:lot_group_item, group_item: group_item, quantity: 3,
                lot: lot)
            end

            before do
              group_item.quantity = 3
              group_item.available_quantity = 2

              group_item.save
              lot_group_item.valid?
            end

            it { is_expected.to eq :less_than_or_equal_to }
          end

          context 'when not draft' do
            let!(:bidding) { create(:bidding, status: :ongoing) }
            let(:lot) { create(:lot, bidding: bidding) }
            let(:group_item) { create(:group_item) }
            let!(:lot_group_item) do
              build(:lot_group_item, group_item: group_item, quantity: 3,
                lot: lot)
            end

            before do
              group_item.quantity = 3
              group_item.available_quantity = 2

              group_item.save
              lot_group_item.valid?
            end

            it { is_expected.not_to eq :less_than_or_equal_to }
          end
        end

        context 'max_quantity' do
          context 'when new record' do
            let!(:group_item) { create(:group_item, quantity: 100) }
            let!(:bidding) { create(:bidding, status: :draft) }
            let(:lot) { create(:lot, bidding: bidding) }
            let(:lot2) { create(:lot, bidding: bidding) }

            let!(:lot_group_item) do
              create(:lot_group_item, group_item: group_item, lot: lot, quantity: 30)
            end

            before do
              allow(lot_group_item).to receive(:new_record?) { true }

              group_item.update_attribute(:available_quantity, 50.29)

              lot_group_item.reload
            end

            it { expect(lot_group_item.send(:max_quantity)).to eq 50.29 }
          end

          context 'when persisted' do
            let!(:group_item) { create(:group_item, quantity: 100.72) }
            let!(:bidding) { create(:bidding, status: :draft) }
            let(:lot) { create(:lot, bidding: bidding) }

            let!(:lot_group_item) do
              create(:lot_group_item, group_item: group_item, lot: lot, quantity: 100.72)
            end

            before do
              allow(lot_group_item).to receive(:new_record?) { false }

              group_item.update_attribute(:available_quantity, 0)

              lot_group_item.reload
            end

            it { expect(lot_group_item.send(:max_quantity)).to eq 100.72 }
          end
        end
      end
    end
  end

  describe 'delegations' do
    it { is_expected.to delegate_method(:draft?).to(:bidding).with_prefix }
  end

  describe 'callbacks' do
    describe 'ensure_quantity' do
      before { lot_group_item.quantity = '10,05'; lot_group_item.valid? }

      it { expect(lot_group_item.quantity).to eq 10.05 }
    end

    describe 'recount_group_item_quantity' do
      let!(:group_item) { create(:group_item, quantity: 100) }
      let!(:bidding) { create(:bidding, status: :draft) }
      let(:lot) { create(:lot, bidding: bidding, status: :failure) }
      let(:lot2) { create(:lot, bidding: bidding) }

      let!(:lot_group_item) do
        create(:lot_group_item, group_item: group_item, lot: lot, quantity: 30)
      end

      let!(:lot_group_item2) do
        create(:lot_group_item, group_item: group_item, lot: lot2, quantity: 50)
      end

      context 'before_destroy' do
        before do
          allow(RecalculateQuantityService).to receive(:call!).with(
            covenant: bidding.covenant,
            lot_group_item: lot_group_item,
            destroying: true
          ).and_return(true)

          group_item.reload

          lot_group_item.destroy
        end

        it do
          expect(RecalculateQuantityService).to have_received(:call!).with(
            covenant: bidding.covenant,
            lot_group_item: lot_group_item,
            destroying: true
          )
        end
      end
    end
  end

  describe 'scopes' do
    describe 'active' do
      let(:group_item) { create(:group_item) }
      let(:lot_group_item_1) { create(:lot_group_item, group_item: group_item) }
      let(:lot_group_item_2) { create(:lot_group_item, group_item: group_item) }
      let(:lot_1) do
        create(:lot, build_lot_group_item: false,
                     lot_group_items: [lot_group_item_1],
                     status: :accepted)
      end
      let(:lot_2) do
        create(:lot, build_lot_group_item: false,
                     lot_group_items: [lot_group_item_2],
                     status: :triage)
      end
      let(:lot_3) do
        create(:lot, build_lot_group_item: false,
                     lot_group_items: [lot_group_item_2],
                     status: :failure)
      end
      let(:lot_4) do
        create(:lot, build_lot_group_item: false,
                     lot_group_items: [lot_group_item_2],
                     status: :desert)
      end
      let(:lot_5) do
        create(:lot, build_lot_group_item: false,
                     lot_group_items: [lot_group_item_2],
                     status: :canceled)
      end

      subject { group_item.lot_group_items.active }

      it { is_expected.to match_array [lot_group_item_1, lot_group_item_2] }
    end
  end

  describe 'behaviors' do
    it { is_expected.to be_versionable }
  end
end
