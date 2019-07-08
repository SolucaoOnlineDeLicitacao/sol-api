class AddPossitionToBiddings < ActiveRecord::Migration[5.2]
  def change
    add_column :biddings, :position, :integer
  end
end
