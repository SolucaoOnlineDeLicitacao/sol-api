module GroupSerializable
  extend ActiveSupport::Concern

  included do
    attributes :id, :name, :covenant_id, :group_items_count, :group_items_value_count
  end

  def group_items_value_count
    object.group_items.inject(0) do |total, group_item|
      total += group_item.estimated_cost * group_item.quantity
    end.to_f
  end
end
