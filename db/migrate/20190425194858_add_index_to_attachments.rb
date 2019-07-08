class AddIndexToAttachments < ActiveRecord::Migration[5.2]
  def change
    add_index :attachments, [:attachable_type, :attachable_id], unique: true
  end
end
