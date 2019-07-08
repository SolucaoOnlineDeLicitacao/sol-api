class AddReferencesToContracts < ActiveRecord::Migration[5.2]
  def change
    add_reference :contracts, :supplier, foreign_key: true
    add_reference :contracts, :admin, foreign_key: true
    add_reference :contracts, :user, foreign_key: true
  end
end
