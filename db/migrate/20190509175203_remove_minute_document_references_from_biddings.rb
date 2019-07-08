class RemoveMinuteDocumentReferencesFromBiddings < ActiveRecord::Migration[5.2]
  def change
    remove_column :biddings, :minute_document_id
  end
end
