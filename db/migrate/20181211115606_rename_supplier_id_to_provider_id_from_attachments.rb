class RenameSupplierIdToProviderIdFromAttachments < ActiveRecord::Migration[5.2]
  def change
    rename_column :attachments, :supplier_id, :provider_id
  end
end
