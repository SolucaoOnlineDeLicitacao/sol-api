class RemoveIdOldFromCities < ActiveRecord::Migration[5.2]
  def change
    remove_column :cities, :id_old, :integer
  end
end
