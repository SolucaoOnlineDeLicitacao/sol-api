class RemoveIndexUniquenessFromAttachments < ActiveRecord::Migration[5.2]
  def change
    remove_index :attachments, [:attachable_type, :attachable_id] # remove unique: true
    add_index :attachments, [:attachable_type, :attachable_id] # readd without unique: true

  end
end
