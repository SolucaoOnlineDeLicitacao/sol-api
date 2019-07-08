class AddAtaDocumentAndNoticeDocumentToBiddings < ActiveRecord::Migration[5.2]
  def change
    add_reference :biddings, :minute_document, index: true, foreign_key: {to_table: :documents}
    add_reference :biddings, :edict_document, index: true, foreign_key: {to_table: :documents}
  end
end
