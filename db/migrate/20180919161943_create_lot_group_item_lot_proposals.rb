class CreateLotGroupItemLotProposals < ActiveRecord::Migration[5.2]
  def change
    create_table :lot_group_item_lot_proposals do |t|
      t.references :lot_group_item, foreign_key: true
      t.references :lot_proposal, foreign_key: true
      t.references :supplier, foreign_key: true
      t.decimal :price

      t.timestamps
    end
  end
end
