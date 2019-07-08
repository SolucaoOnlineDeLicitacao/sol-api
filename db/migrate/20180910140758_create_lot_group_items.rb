class CreateLotGroupItems < ActiveRecord::Migration[5.2]
  def change
    create_table :lot_group_items do |t|
      t.references :lot, foreign_key: true
      t.references :group_item, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
  end
end
