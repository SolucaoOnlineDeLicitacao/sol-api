class AddIndexToLotProposals < ActiveRecord::Migration[5.2]
  def change
		add_index(:lot_proposals, [:lot_id, :supplier_id], unique: true)
  end
end
