class AddSpreadsheetReportToBiddings < ActiveRecord::Migration[5.2]
  def change
    add_reference :biddings, :spreadsheet_report, index: true, foreign_key: {to_table: :documents}
  end
end
