class CreateBiddingsAndMinuteDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :biddings_and_minute_documents, id: false do |t|
      t.references :bidding, foreign_key: true
      t.references :minute_document, foreign_key: {to_table: :documents}
    end
  end
end
