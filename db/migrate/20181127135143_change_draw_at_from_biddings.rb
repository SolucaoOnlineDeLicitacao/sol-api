class ChangeDrawAtFromBiddings < ActiveRecord::Migration[5.2]
  def change
    change_column :biddings, :draw_at, :date
  end
end
