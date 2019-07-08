class AddAvailableQuantityToGroupItems < ActiveRecord::Migration[5.2]
  def change
    add_column :group_items, :available_quantity, :integer
  end
end
