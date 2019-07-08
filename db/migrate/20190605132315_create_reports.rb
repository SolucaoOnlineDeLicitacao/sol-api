class CreateReports < ActiveRecord::Migration[5.2]
  def change
    create_table :reports do |t|
      t.references :admin, foreign_key: true
      t.integer :report_type, default: 0
      t.integer :status, default: 0
      t.string :url
      t.string :error_message
      t.text :error_backtrace

      t.timestamps
    end
  end
end
