require 'rails_helper'

RSpec.describe Item, type: :model do

  describe 'associations' do
    it { is_expected.to belong_to :owner }
    it { is_expected.to belong_to :classification }
    it { is_expected.to belong_to :unit }

    it { is_expected.to have_many(:group_items).dependent(:destroy) }
    it { is_expected.to have_many(:lot_group_items).through(:group_items) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :owner }
    it { is_expected.to validate_presence_of :code }

    context 'code uniqueness' do
      before { build(:item) }

      it do
        is_expected.to validate_uniqueness_of(:code)
      end
    end

    context 'title and code uniqueness' do
      before { build(:item) }

      it do
        is_expected.to validate_uniqueness_of(:title)
          .scoped_to(:code).case_insensitive
      end
    end

    describe 'before_destroy' do
      describe 'lot_group_items_in_use?' do
        let!(:item) { create(:item) }

        before do
          allow(item).to receive(:throw).with(:abort).and_call_original
        end

        context 'when true' do
          let(:group_item) { create(:group_item, item: item) }
          let!(:lot_group_item) do
            create(:lot_group_item, group_item: group_item)
          end
          let(:lot) do
            create(:lot, build_lot_group_item: false,
                         lot_group_items: [lot_group_item])
          end
          let!(:bidding) do
            create(:bidding, build_lot: false, lots: [lot], status: :waiting)
          end

          it do
            item.destroy
            expect(item).to have_received(:throw).with(:abort)
          end
        end

        context 'when false' do
          it do
            item.destroy
            expect(item).not_to have_received(:throw).with(:abort)
          end
        end
      end
    end

    describe 'item_modification' do
      let(:item) { create(:item, title: 'test') }
      let(:error) { 'não pode ser alterado pois o item está em uso' }
      let(:item_code_factor) { 100 }

      before do
        allow(Notifications::Biddings::Items::Cooperative).to receive(:call)
      end

      context 'when updating' do
        before { item.title = 'new title' }

        subject { item.valid? }

        context 'and the item is in use' do
          let(:group_item) { create(:group_item, item: item) }
          let!(:lot_group_item) do
            create(:lot_group_item, group_item: group_item)
          end
          let(:lot) do
            create(:lot, build_lot_group_item: false,
                         lot_group_items: [lot_group_item])
          end
          let!(:bidding) do
            create(:bidding, build_lot: false, lots: [lot], status: status)
          end

          context 'and the item is in 1 bidding' do
            context 'with status waiting' do
              let(:status) { :waiting }

              it { is_expected.to be_falsey }

              describe 'the error message' do
                before { subject }

                it do
                  expect(item.errors.messages[:lot_group_items].first).
                    to eq(error)
                end
              end

              describe 'the after_update_commit callback notify_users' do
                before { item.save }

                it do
                  expect(Notifications::Biddings::Items::Cooperative).
                    to_not have_received(:call).with(bidding, item)
                end
              end

              context 'and changing permitted attribute' do
                let(:new_code) { item.code + item_code_factor }

                before do
                  item.restore_attributes
                  item.code = new_code
                end

                it { is_expected.to be_truthy }
                it { expect(item.code).to eq(new_code) }
              end
            end

            context 'with status draft' do
              let(:status) { :draft }

              it { is_expected.to be_truthy }

              describe 'the after_update_commit callback notify_users' do
                before { item.save }

                it do
                  expect(Notifications::Biddings::Items::Cooperative).
                    to have_received(:call).with(bidding, item)
                end
              end

              context 'and changing permitted attribute' do
                let(:new_code) { item.code + item_code_factor }

                before do
                  item.restore_attributes
                  item.code = new_code
                end

                it { is_expected.to be_truthy }
                it { expect(item.code).to eq(new_code) }
              end
            end
          end

          context 'and the item is in 2 biddings' do
            let!(:another_lot_group_item) do
              create(:lot_group_item, group_item: group_item)
            end
            let(:another_lot) do
              create(:lot, build_lot_group_item: false,
                           lot_group_items: [another_lot_group_item])
            end
            let!(:another_bidding) do
              create(:bidding, build_lot: false,
                               lots: [another_lot],
                               status: another_status)
            end

            context 'with status waiting and draft' do
              let(:status) { :waiting }
              let(:another_status) { :draft }

              it { is_expected.to be_falsey }

              describe 'the error message' do
                before { subject }

                it do
                  expect(item.errors.messages[:lot_group_items].first).
                    to eq(error)
                end
              end

              describe 'the after_update_commit callback notify_users' do
                before { item.save }

                it do
                  expect(Notifications::Biddings::Items::Cooperative).
                    to_not have_received(:call).with(bidding, item)
                end
              end

              context 'and changing permitted attribute' do
                let(:new_code) { item.code + item_code_factor }

                before do
                  item.restore_attributes
                  item.code = new_code
                end

                it { is_expected.to be_truthy }
                it { expect(item.code).to eq(new_code) }
              end
            end

            context 'with all status waiting' do
              let(:status) { :waiting }
              let(:another_status) { :waiting }

              it { is_expected.to be_falsey }

              describe 'the error message' do
                before { subject }

                it do
                  expect(item.errors.messages[:lot_group_items].first).
                    to eq(error)
                end
              end

              describe 'the after_update_commit callback notify_users' do
                before { item.save }

                it do
                  expect(Notifications::Biddings::Items::Cooperative).
                    to_not have_received(:call).with(bidding, item)
                end
              end

              context 'and changing permitted attribute' do
                let(:new_code) { item.code + item_code_factor }

                before do
                  item.restore_attributes
                  item.code = new_code
                end

                it { is_expected.to be_truthy }
                it { expect(item.code).to eq(new_code) }
              end
            end

            context 'with all status draft' do
              let(:status) { :draft }
              let(:another_status) { :draft }

              it { is_expected.to be_truthy }

              describe 'the after_update_commit callback notify_users' do
                before { item.save }

                it do
                  expect(Notifications::Biddings::Items::Cooperative).
                    to have_received(:call).with(bidding, item)
                end
              end

              context 'and changing permitted attribute' do
                let(:new_code) { item.code + item_code_factor }

                before do
                  item.restore_attributes
                  item.code = new_code
                end

                it { is_expected.to be_truthy }
                it { expect(item.code).to eq(new_code) }
              end
            end
          end
        end

        context 'and the item is not in use' do
          it { is_expected.to be_truthy }

          describe 'the after_update_commit callback notify_users' do
            before { item.save }

            it do
              expect(Notifications::Biddings::Items::Cooperative).
                to_not have_received(:call)
            end
          end
        end
      end

      context 'when creating' do
        let(:item) { build(:item) }

        subject { item.valid? }

        it { is_expected.to be_truthy }

        describe 'the after_update_commit callback notify_users' do
          before { item.save }

          it do
            expect(Notifications::Biddings::Items::Cooperative).
              to_not have_received(:call)
          end
        end
      end
    end
  end

  describe 'delegations' do
    it { is_expected.to delegate_method(:name).to(:owner).with_prefix }
  end

  describe 'sortable' do
    it { expect(described_class.default_sort_column).to eq 'items.title' }
  end

  describe 'methods' do
    describe 'text' do
      let(:item) { create(:item) }

      let(:expected) do
        "#{item.classification_name} / #{item.title} - #{item.description}"
      end

      it { expect(item.text).to eq expected }
    end
  end

  describe 'behaviors' do
    it { is_expected.to be_versionable }
  end
end
