class AddPositionToLots < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :position, :integer
  end
end
