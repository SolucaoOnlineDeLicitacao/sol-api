class AddDocumentReferencesToBiddings < ActiveRecord::Migration[5.2]
  def change
    add_reference :biddings, :document, foreign_key: true
  end
end
