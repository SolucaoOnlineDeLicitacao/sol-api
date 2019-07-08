class RemoveUnitFromItems < ActiveRecord::Migration[5.2]
  def change
    remove_column :items, :unit, :integer
  end
end
