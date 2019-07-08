class AddDeletedAtToContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :deleted_at, :datetime
  end
end
