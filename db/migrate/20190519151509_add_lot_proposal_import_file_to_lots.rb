class AddLotProposalImportFileToLots < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :lot_proposal_import_file, :string
  end
end
