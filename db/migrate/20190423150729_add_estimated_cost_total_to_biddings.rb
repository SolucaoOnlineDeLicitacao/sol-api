class AddEstimatedCostTotalToBiddings < ActiveRecord::Migration[5.2]
  def change
    add_column :biddings, :estimated_cost_total, :float
  end
end
