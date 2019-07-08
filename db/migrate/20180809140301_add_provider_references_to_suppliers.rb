class AddProviderReferencesToSuppliers < ActiveRecord::Migration[5.2]
  def change
    add_reference :suppliers, :provider, foreign_key: true
  end
end
