class ChangeLotProposalImportJobsToLotProposalImports < ActiveRecord::Migration[5.2]
  def change
    rename_table :lot_proposal_import_jobs, :lot_proposal_imports
  end
end
