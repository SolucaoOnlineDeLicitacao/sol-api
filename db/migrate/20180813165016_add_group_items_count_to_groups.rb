class AddGroupItemsCountToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :group_items_count, :integer, default: 0
  end
end
