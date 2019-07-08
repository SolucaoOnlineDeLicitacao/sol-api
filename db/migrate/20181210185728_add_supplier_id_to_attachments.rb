class AddSupplierIdToAttachments < ActiveRecord::Migration[5.2]
  def change
    add_reference :attachments, :supplier, foreign_key: true, index: true
  end
end
