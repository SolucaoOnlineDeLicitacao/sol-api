class AddParentIdToLotProposals < ActiveRecord::Migration[5.2]
  def change
    add_column :lot_proposals, :parent_id, :bigint
  end
end
