class AddDrawEndDaysToBiddings < ActiveRecord::Migration[5.2]
  def change
    add_column :biddings, :draw_end_days, :integer, default: 0
  end
end
