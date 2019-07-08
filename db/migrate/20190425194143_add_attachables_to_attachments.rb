class AddAttachablesToAttachments < ActiveRecord::Migration[5.2]
  def change
    add_column :attachments, :attachable_type, :string
    add_column :attachments, :attachable_id, :bigint
  end
end
