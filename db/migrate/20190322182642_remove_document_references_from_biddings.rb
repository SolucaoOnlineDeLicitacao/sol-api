class RemoveDocumentReferencesFromBiddings < ActiveRecord::Migration[5.2]
  def change
    remove_reference :biddings, :document, index: true, foreign_key: true
  end
end
