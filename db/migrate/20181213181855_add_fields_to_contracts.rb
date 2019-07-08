class AddFieldsToContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :supplier_signed_at, :datetime
    add_column :contracts, :admin_signed_at, :datetime
    add_column :contracts, :user_signed_at, :datetime
  end
end
