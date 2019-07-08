class RemoveProviderIdFromContracts < ActiveRecord::Migration[5.2]
  def change
    remove_column :contracts, :provider_id, :bigint
  end
end
