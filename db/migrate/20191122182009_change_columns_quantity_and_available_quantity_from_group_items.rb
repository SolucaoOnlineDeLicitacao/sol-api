class ChangeColumnsQuantityAndAvailableQuantityFromGroupItems < ActiveRecord::Migration[5.2]
  def change
    change_column :group_items, :quantity, :decimal, precision: 10, scale: 2 # max 99_999_999.99
    change_column :group_items, :available_quantity, :decimal, precision: 10, scale: 2 # max 99_999_999.99
  end
end