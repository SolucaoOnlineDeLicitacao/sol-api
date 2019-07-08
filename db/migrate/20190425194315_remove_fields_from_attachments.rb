class RemoveFieldsFromAttachments < ActiveRecord::Migration[5.2]
  def change
    remove_reference :attachments, :provider, index: true
    remove_reference :attachments, :lot
  end
end
