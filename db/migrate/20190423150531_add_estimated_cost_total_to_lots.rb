class AddEstimatedCostTotalToLots < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :estimated_cost_total, :float
  end
end
