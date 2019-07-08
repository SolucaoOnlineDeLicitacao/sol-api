class AddProviderIdToContracts < ActiveRecord::Migration[5.2]
  def change
    add_reference :contracts, :provider, foreign_key: true
  end
end
