class CreateReturnedLotGroupItems < ActiveRecord::Migration[5.2]
  def change
    create_table :returned_lot_group_items do |t|
      t.integer :quantity
      t.bigint :contract_id
      t.bigint :lot_group_item_id

      t.timestamps
    end
  end
end
