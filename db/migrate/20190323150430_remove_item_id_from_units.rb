class RemoveItemIdFromUnits < ActiveRecord::Migration[5.2]
  def change
    remove_column :units, :item_id, :bigint
  end
end
