class CreateGroupItems < ActiveRecord::Migration[5.2]
  def change
    create_table :group_items do |t|
      t.references :group, foreign_key: true
      t.references :item, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
  end
end
