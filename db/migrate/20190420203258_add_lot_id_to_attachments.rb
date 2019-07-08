class AddLotIdToAttachments < ActiveRecord::Migration[5.2]
  def change
    add_column :attachments, :lot_id, :bigint
  end
end
