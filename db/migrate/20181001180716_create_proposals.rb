class CreateProposals < ActiveRecord::Migration[5.2]
  def change
    create_table :proposals do |t|
      t.references :bidding, foreign_key: true
      t.references :provider, foreign_key: true
      t.integer :status
      t.decimal :price_total

      t.timestamps
    end
  end
end
