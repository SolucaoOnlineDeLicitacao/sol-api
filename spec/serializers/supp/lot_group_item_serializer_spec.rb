require 'rails_helper'

RSpec.describe Supp::LotGroupItemSerializer, type: :serializer do
  let(:object) { create :lot_group_item }
  let(:supplier) { create(:supplier) }

  subject { format_json(described_class, object, scope: supplier) }

  describe 'attributes' do
    let(:lot_group_item_count) do
      object.bidding.lots.joins(:group_items)
      .where(group_items: { item_id: object.group_item.item_id }).count
    end

    let(:lot_group_item_lot_proposals) do
      hash = []

      lot_group_item_lot_proposals = LotGroupItemLotProposal.joins(:group_item, :provider, :bidding)
        .where(
          group_items: { id: object&.group_item&.id },
          providers: { id: supplier&.id }
        )

      lot_group_item_lot_proposals.map do |lot_group_item_lot_proposal|
        _lot_group_item_lot_proposal = lot_group_item_lot_proposal.as_json

        _lot_group_item_lot_proposal.merge!(bidding_id: lot_group_item_lot_proposal&.bidding&.id)

        hash << _lot_group_item_lot_proposal
      end

      hash
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
    it { is_expected.to include 'lot_group_item_lot_proposals' => lot_group_item_lot_proposals }
  end
end
