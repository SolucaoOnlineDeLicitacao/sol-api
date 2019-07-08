class AddProposalImportFileToBiddings < ActiveRecord::Migration[5.2]
  def change
    add_column :biddings, :proposal_import_file, :string
  end
end
