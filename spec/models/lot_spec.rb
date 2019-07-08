require 'rails_helper'

RSpec.describe Lot, type: :model do
  let(:lot) { build(:lot) }

  describe 'factory' do
    let(:factory) { build(:lot) }

    subject { factory }

    it { is_expected.to be_valid }
  end

  describe 'mount_uploader' do
    it { expect(subject.lot_proposal_import_file).to be_a(FileUploader) }
  end

  describe 'enums' do
    let(:statuses) do
      { draft: 0, waiting: 1, triage: 2, accepted: 3, failure: 4, desert: 5, canceled: 6  }
    end

    it { is_expected.to define_enum_for(:status).with_values(statuses) }
  end

  describe 'associations' do
    it { is_expected.to belong_to :bidding }
    it { is_expected.to have_many(:lot_group_items).dependent(:destroy) }
    it { is_expected.to have_many(:lot_proposals).dependent(:destroy) }
    it { is_expected.to have_many(:proposals).through(:lot_proposals) }
    it { is_expected.to have_many(:group_items).through(:lot_group_items) }
    it { is_expected.to have_many(:lot_proposal_imports).dependent(:destroy) }
    it { is_expected.to have_many(:attachments).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :bidding }
    it { is_expected.to validate_presence_of :name }

    describe 'uniqueness' do
      before { build(:lot) }

      it do
        is_expected.to validate_uniqueness_of(:name)
          .scoped_to(:bidding_id).case_insensitive
      end
    end

    describe 'lot_group_items minimum' do
      subject { lot }

      context 'when <= 0' do
        before do
          lot.lot_group_items.destroy_all
          lot.valid?
        end

        it { is_expected.to include_error_key_for(:lot_group_items, :too_short) }
      end

      context 'when > 0' do
        it { expect(lot.lot_group_items).to be_present }
        it { is_expected.not_to include_error_key_for(:lot_group_items, :too_short) }
      end
    end

    describe 'bidding kind' do
      subject { lot }

      context 'when unitary' do
        let(:bidding) { create(:bidding, kind: :unitary) }
        let!(:lot) { bidding.lots.first }
        let(:lot_group_item) { build(:lot_group_item) }

        subject { lot }

        context 'when not marked_for_destruction' do
          before do
            lot.lot_group_items << lot_group_item
          end

          it { is_expected.to include_error_key_for(:lot_group_items, :too_many) }
        end

        context 'when marked_for_destruction' do
          before do
            lot_group_item.mark_for_destruction

            lot.lot_group_items << lot_group_item
          end

          it { is_expected.not_to include_error_key_for(:lot_group_items, :too_many) }
        end
      end

      context 'when lot' do
        let(:bidding) { create(:bidding, kind: :lot) }
        let!(:lot) { bidding.lots.first }
        let(:lot_group_item) { build(:lot_group_item) }

        subject { lot }

        before { lot.lot_group_items << lot_group_item }

        it { is_expected.not_to include_error_key_for(:lot_group_items, :too_many) }
        it { expect(lot.lot_group_items.size).to eq 2 }
      end

      context 'when global' do
        let(:bidding) { create(:bidding, kind: :global) }
        let!(:lot) { bidding.lots.first }
        let(:lot_group_item) { build(:lot_group_item) }

        subject { lot }

        before { lot.lot_group_items << lot_group_item }

        it { is_expected.not_to include_error_key_for(:lot_group_items, :too_many) }
        it { expect(lot.lot_group_items.size).to eq 2 }
      end
    end
  end

  describe 'nesteds' do
    it do
      is_expected.to accept_nested_attributes_for(:lot_group_items)
        .allow_destroy(true)
    end

    it do
      is_expected.to accept_nested_attributes_for(:attachments)
        .allow_destroy(true)
    end
  end

  describe 'sortable' do
    it { expect(described_class.default_sort_column).to eq 'lots.position' }
  end

  describe 'scope' do
    context '.sorted' do
      let(:bidding_1) { create(:bidding, kind: :lot) }
      let!(:lot_1) { bidding_1.lots.first }
      let!(:lot_2) { create(:lot, bidding: bidding_1) }
      let!(:lot_3) { create(:lot, bidding: bidding_1) }

      let(:bidding_2) { create(:bidding, kind: :lot) }
      let!(:lot_4) { bidding_2.lots.first }
      let!(:lot_5) { create(:lot, bidding: bidding_2) }
      let!(:lot_6) { create(:lot, bidding: bidding_2) }

      it { expect(Lot.sorted).to match_array [lot_1, lot_4, lot_2, lot_5, lot_3, lot_6] }
      it { expect(bidding_1.reload.lots.sorted).to eq [lot_1, lot_2, lot_3] }
      it { expect(bidding_2.reload.lots.sorted).to eq [lot_4, lot_5, lot_6] }
    end

    context '.proposals_not_draft_or_abandoned' do
      let!(:bidding) { create(:bidding, kind: :lot) }
      let!(:lot_1) { bidding.lots.first }
      let!(:lot_2) { create(:lot, bidding: bidding) }
      let!(:lot_3) { create(:lot, bidding: bidding) }
      let!(:proposal_a_lot_1) do
        create(:proposal, bidding: bidding, lot: lot_1, status: :sent, price_total: 5001,
          sent_updated_at: DateTime.now)
      end

      let!(:proposal_b_lot_1) do
        create(:proposal, bidding: bidding, lot: lot_1, status: :sent, price_total: 5000,
          sent_updated_at: DateTime.now+1.day)
      end

      subject { lot_1 }

      it { expect(subject.proposals_not_draft_or_abandoned.size).to eq 2 }
    end
  end

  describe 'callbacks' do
    let(:bidding_1) { create(:bidding, kind: :lot) }
    let!(:lot_1) { bidding_1.lots.first }
    let!(:lot_2) { create(:lot, bidding: bidding_1) }
    let!(:lot_3) { create(:lot, bidding: bidding_1) }

    let(:bidding_2) { create(:bidding, kind: :lot) }
    let!(:lot_4) { bidding_2.lots.first }
    let!(:lot_5) { create(:lot, bidding: bidding_2) }
    let!(:lot_6) { create(:lot, bidding: bidding_2) }

    describe '.update_position' do
      it { expect(lot_1.position).to eq 1 }
      it { expect(lot_2.position).to eq 2 }
      it { expect(lot_3.position).to eq 3 }

      it { expect(lot_4.position).to eq 1 }
      it { expect(lot_5.position).to eq 2 }
      it { expect(lot_6.position).to eq 3 }
    end

    describe '.update_estimated_cost_total' do
      let(:group_item_1) { build(:group_item, quantity: 100, estimated_cost: 20) }
      let(:group_item_2) { build(:group_item, quantity: 100, estimated_cost: 10) }
      let(:lot_group_item_1) { build(:lot_group_item, group_item: group_item_1, quantity: 10) }
      let(:lot_group_item_2) { build(:lot_group_item, group_item: group_item_2, quantity: 10) }

      let(:estimated_cost_total_1) { 300 }

      before do
        lot_1.lot_group_items.destroy_all
        lot_1.lot_group_items << [lot_group_item_1, lot_group_item_2]
        lot_1.save
      end

      it { expect(lot_1.estimated_cost_total).to eq estimated_cost_total_1 }
    end

    describe '.update_position_bidding_lots' do
      context 'when destroy lot 1' do
        before { lot_1.destroy }

        it { expect(lot_2.reload.position).to eq 1 }
        it { expect(lot_3.reload.position).to eq 2 }
      end

      context 'when destroy lot 2' do
        before { lot_2.destroy }

        it { expect(lot_1.reload.position).to eq 1 }
        it { expect(lot_3.reload.position).to eq 2 }
      end

      context 'when destroy lot 3' do
        before { lot_3.destroy }

        it { expect(lot_1.reload.position).to eq 1 }
        it { expect(lot_2.reload.position).to eq 2 }
      end

      context 'when destroy lot 4' do
        before { lot_4.destroy }

        it { expect(lot_5.reload.position).to eq 1 }
        it { expect(lot_6.reload.position).to eq 2 }
      end

      context 'when destroy lot 5' do
        before { lot_5.destroy }

        it { expect(lot_4.reload.position).to eq 1 }
        it { expect(lot_6.reload.position).to eq 2 }
      end

      context 'when destroy lot 6' do
        before { lot_6.destroy }

        it { expect(lot_4.reload.position).to eq 1 }
        it { expect(lot_5.reload.position).to eq 2 }
      end
    end
  end

  describe 'behaviors' do
    it { is_expected.to be_versionable }
  end
end
