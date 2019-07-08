require 'rails_helper'

RSpec.describe Coop::LotSerializer, type: :serializer do
  let(:object) { create :lot }

  subject { format_json(described_class, object) }

  describe 'attributes' do
    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'name' => object.name }
    it { is_expected.to include 'title' => "#{object.position} - #{object.name}" }
    it { is_expected.to include 'deadline' => object.deadline }
    it { is_expected.to include 'address' => object.address }
    it { is_expected.to include 'bidding_id' => object.bidding_id }
    it { is_expected.to include 'bidding_title' => object.bidding.title }
    it { is_expected.to include 'bidding_status' => object.bidding.status }
    it { is_expected.to include 'bidding_kind' => object.bidding.kind }
    it { is_expected.to include 'bidding_modality' => object.bidding.modality }
    it { is_expected.to include 'bidding_proposals_count' => object.bidding.proposals.sent.count }
    it { is_expected.to include 'status' => object.status }
    it { is_expected.to include 'lot_proposals_count' => object.lot_proposals.count }
    it { is_expected.to include 'lot_group_items_count' => object.lot_group_items_count }
    it { is_expected.to include 'position' => object.position }
    it { is_expected.to include 'estimated_cost_total' => object.estimated_cost_total }
  end

  describe 'associations' do
    describe 'lot_group_items' do
      before { create(:lot_group_item, lot: object) }

      let(:serialized_lot_group_items) do
        object.lot_group_items.map do |lot_group_item|
          format_json(Coop::LotGroupItemSerializer, lot_group_item)
        end
      end

      it { is_expected.to include 'lot_group_items' => serialized_lot_group_items }
    end

    describe 'attachments' do
      let(:serialized_attachments) do
        object.attachments.map { |attachment| format_json(AttachmentSerializer, attachment) }
      end

      it { is_expected.to include 'attachments' => serialized_attachments }
    end
  end

end
