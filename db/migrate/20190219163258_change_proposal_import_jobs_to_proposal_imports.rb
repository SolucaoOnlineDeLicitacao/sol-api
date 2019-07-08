class ChangeProposalImportJobsToProposalImports < ActiveRecord::Migration[5.2]
  def change
     rename_table :proposal_import_jobs, :proposal_imports
  end
end
