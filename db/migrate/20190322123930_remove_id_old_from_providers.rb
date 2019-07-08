class RemoveIdOldFromProviders < ActiveRecord::Migration[5.2]
  def change
    remove_column :providers, :id_old, :integer
  end
end
