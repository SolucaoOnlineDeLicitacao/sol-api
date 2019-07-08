class CreateLots < ActiveRecord::Migration[5.2]
  def change
    create_table :lots do |t|
      t.references :bidding, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
