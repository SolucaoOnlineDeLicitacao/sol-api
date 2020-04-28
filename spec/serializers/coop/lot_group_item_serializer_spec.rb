require 'rails_helper'

RSpec.describe Coop::LotGroupItemSerializer, type: :serializer do
  let(:object) { create :lot_group_item }

  subject { format_json(described_class, object) }

  describe 'attributes' do
    let(:lot_name) { object.lot.name }

    let(:lot_group_item_count) do
      object.bidding.lots.joins(:group_items)
      .where(group_items: { item_id: object.group_item.item_id }).uniq.count
    end

    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'lot_id' => object.lot_id }
    it { is_expected.to include 'group_item_id' => object.group_item_id }
    it { is_expected.to include 'item_short_name' => object.group_item.item.title }
    it { is_expected.to include 'item_name' => object.group_item.item.text }
    it { is_expected.to include 'item_unit' => object.group_item.unit.name }
    it { is_expected.to include 'quantity' => object.quantity.to_s }
    it { is_expected.to include 'total_quantity' => object.group_item.quantity.to_s }
    it { is_expected.to include 'available_quantity' => object.group_item.available_quantity.to_s }
    it { is_expected.to include 'current_quantity' => object.quantity.to_s }
    it { is_expected.to include '_destroy' => object._destroy }
    it { is_expected.to include 'lot_group_item_count' => lot_group_item_count }
    it { is_expected.to include 'lot_name' => lot_name }
  end
end
