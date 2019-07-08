class CreateAttachments < ActiveRecord::Migration[5.2]
  def change
    create_table :attachments do |t|
      t.integer :status, default: 0
      t.string :file

      t.timestamps
    end
  end
end
