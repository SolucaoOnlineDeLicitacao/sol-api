module Coop
  class LotGroupItemSerializer < ActiveModel::Serializer
    attributes :id, :lot_id, :group_item_id, :item_short_name,
                :item_name, :item_unit, :quantity, :current_quantity, :total_quantity,
                :available_quantity, :lot_group_item_count, :_destroy, :lot_name

    def current_quantity
      object.quantity
    end

    def lot_group_item_count
      object.bidding.lots.joins(:group_items).where(group_items: { item_id: object.group_item.item_id }).uniq.count
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

    def lot_name
      object.lot.name
    end
  end
end
