class AddDrawEndAndDrawAtToBiddings < ActiveRecord::Migration[5.2]
  def change
    add_column :biddings, :draw_end, :time
    add_column :biddings, :draw_at, :datetime
  end
end
