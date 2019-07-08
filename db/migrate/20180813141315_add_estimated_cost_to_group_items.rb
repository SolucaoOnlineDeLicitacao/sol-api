class AddEstimatedCostToGroupItems < ActiveRecord::Migration[5.2]
  def change
    add_column :group_items, :estimated_cost, :float
  end
end
