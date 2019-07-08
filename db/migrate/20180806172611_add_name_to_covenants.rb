class AddNameToCovenants < ActiveRecord::Migration[5.2]
  def change
    add_column :covenants, :name, :string
  end
end
