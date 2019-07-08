class RemoveSupplierReferencesFromLotGroupItemLotProposals < ActiveRecord::Migration[5.2]
  def change
    remove_reference :lot_group_item_lot_proposals, :supplier
  end
end
