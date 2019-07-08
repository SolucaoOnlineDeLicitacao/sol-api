class AddLotProposalsCountToLots < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :lot_proposals_count, :integer
  end
end
