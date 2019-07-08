class AddUnitIdToItems < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :unit_id, :integer
  end
end
