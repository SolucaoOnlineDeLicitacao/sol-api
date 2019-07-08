class RemoveForeignKeyAttachments < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key "attachments", "suppliers"
  end
end
