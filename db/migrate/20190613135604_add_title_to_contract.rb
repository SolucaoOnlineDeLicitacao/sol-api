class AddTitleToContract < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :title, :string
  end
end
