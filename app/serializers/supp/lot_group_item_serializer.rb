module Supp
  class LotGroupItemSerializer < ActiveModel::Serializer
    attributes :id, :lot_id, :group_item_id, :item_short_name,
                :item_name, :item_unit, :quantity, :current_quantity, :total_quantity,
                :available_quantity, :lot_group_item_count, :lot_group_item_lot_proposals, :_destroy

    def current_quantity
      object.quantity
    end

    def lot_group_item_count
      object.bidding.lots.joins(:group_items).where(group_items: { item_id: object.group_item.item_id }).count
    end

    def lot_group_item_lot_proposals
      hash = []

      lot_group_item_lot_proposals = LotGroupItemLotProposal.joins(:group_item, :provider, :bidding)
        .where(
          group_items: { id: object&.group_item&.id },
          providers: { id: current_provider&.id }
        )

      lot_group_item_lot_proposals.map do |lot_group_item_lot_proposal|
        _lot_group_item_lot_proposal = lot_group_item_lot_proposal.as_json

        _lot_group_item_lot_proposal.merge!(bidding_id: lot_group_item_lot_proposal&.bidding&.id)

        hash << _lot_group_item_lot_proposal
      end

      hash
    end

    def item_name
      object.group_item.item.text
    end

    def item_short_name
      object.group_item.item.title
    end

    def item_unit
      object.group_item.unit.name
    end

    def total_quantity
      object.group_item.quantity
    end

    def available_quantity
      object.group_item.available_quantity
    end

    private

    def current_provider
      @instance_options[:scope]&.provider
    end
  end
end
