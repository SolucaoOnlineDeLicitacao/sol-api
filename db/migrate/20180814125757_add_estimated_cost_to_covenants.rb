class AddEstimatedCostToCovenants < ActiveRecord::Migration[5.2]
  def change
    add_column :covenants, :estimated_cost, :float
  end
end
