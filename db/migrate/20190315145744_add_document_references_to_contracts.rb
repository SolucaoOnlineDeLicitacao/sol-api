class AddDocumentReferencesToContracts < ActiveRecord::Migration[5.2]
  def change
    add_reference :contracts, :document, foreign_key: true
  end
end
