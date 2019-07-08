class RemoveAdminSignedAtFromContracts < ActiveRecord::Migration[5.2]
  def change
    remove_column :contracts, :admin_signed_at, :datetime
  end
end
