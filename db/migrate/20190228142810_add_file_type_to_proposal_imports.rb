class AddFileTypeToProposalImports < ActiveRecord::Migration[5.2]
  def change
    add_column :proposal_imports, :file_type, :integer, default: 0
  end
end
