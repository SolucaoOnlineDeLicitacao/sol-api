class CreateLotProposals < ActiveRecord::Migration[5.2]
  def change
    create_table :lot_proposals do |t|
      t.references :lot, foreign_key: true
      t.references :provider, foreign_key: true
      t.decimal :price_total
      t.integer :status

      t.timestamps
    end
  end
end
