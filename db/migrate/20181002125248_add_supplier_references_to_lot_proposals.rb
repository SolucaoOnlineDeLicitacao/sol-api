class AddSupplierReferencesToLotProposals < ActiveRecord::Migration[5.2]
  def change
    add_reference :lot_proposals, :supplier, foreign_key: true
  end
end
