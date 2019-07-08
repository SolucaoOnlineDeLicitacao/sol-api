class RemoveDrawEndFromBiddings < ActiveRecord::Migration[5.2]
  def change
    remove_column :biddings, :draw_end, :time
  end
end
