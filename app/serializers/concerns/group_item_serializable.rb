module GroupItemSerializable
  extend ActiveSupport::Concern

  included do
    attributes :id, :item_id, :item_short_name, :item_name, :item_unit, :quantity,
               :available_quantity, :group_name, :estimated_cost, :_destroy
  end

  def item_name
    object.item.text
  end

  def item_short_name
    object.item.title
  end

  def item_unit
    object.item.unit_name
  end

  def group_name
    object.group.name
  end
end
