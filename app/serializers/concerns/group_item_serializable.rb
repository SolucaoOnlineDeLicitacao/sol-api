module GroupItemSerializable
  extend ActiveSupport::Concern

  included do
    attributes :id, :item_id, :item_short_name, :item_name, :item_unit, :quantity,
               :available_quantity, :group_id, :group_name, :estimated_cost, :_destroy
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

  def group_id
    object.group_id
  end

  def group_name
    object.group.name
  end

  def quantity
    object.quantity.to_f
  end

  def available_quantity
    object.available_quantity.to_f
  end

  def estimated_cost
    object.estimated_cost.to_f
  end
end
