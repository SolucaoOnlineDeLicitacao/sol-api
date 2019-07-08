class AddCodeToItems < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :code, :integer, index: true
  end
end
