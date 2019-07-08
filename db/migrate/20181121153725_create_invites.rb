class CreateInvites < ActiveRecord::Migration[5.2]
  def change
    create_table :invites do |t|
      t.integer :status
      t.references :provider, foreign_key: true
      t.references :bidding, foreign_key: true

      t.timestamps
    end
  end
end
