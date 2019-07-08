class AddLotGroupItemsCountToLots < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :lot_group_items_count, :integer
  end
end
