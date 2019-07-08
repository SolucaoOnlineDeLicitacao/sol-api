class AddMergedMinuteDocumentToBiddings < ActiveRecord::Migration[5.2]
  def change
    add_reference :biddings, :merged_minute_document, index: true, foreign_key: {to_table: :documents}
  end
end
