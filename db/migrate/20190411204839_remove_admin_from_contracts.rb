class RemoveAdminFromContracts < ActiveRecord::Migration[5.2]
  def change
    remove_reference :contracts, :admin, foreign_key: true
  end
end
