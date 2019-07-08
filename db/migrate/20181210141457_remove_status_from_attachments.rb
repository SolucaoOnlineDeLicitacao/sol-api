class RemoveStatusFromAttachments < ActiveRecord::Migration[5.2]
  def change
    remove_column :attachments, :status, :integer
  end
end
