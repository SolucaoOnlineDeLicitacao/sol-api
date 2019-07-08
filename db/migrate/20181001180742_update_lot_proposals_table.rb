class UpdateLotProposalsTable < ActiveRecord::Migration[5.2]
  def change
    remove_reference :lot_proposals, :provider
    remove_column :lot_proposals, :status
    add_reference :lot_proposals, :proposal
  end
end
