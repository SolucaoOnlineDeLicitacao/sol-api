class AddIdOldToCities < ActiveRecord::Migration[5.2]
  def change
    add_column :cities, :id_old, :integer
  end
end
