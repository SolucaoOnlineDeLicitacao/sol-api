class CreateLotProposalImportJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :lot_proposal_import_jobs do |t|
      t.references :provider, foreign_key: true
      t.references :bidding, foreign_key: true
      t.references :lot, foreign_key: true
      t.string :file, null: false
      t.string :error_message
      t.text :error_backtrace
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
