class AddIdOldToProviders < ActiveRecord::Migration[5.2]
  def change
    add_column :providers, :id_old, :integer, default: 0
  end
end
