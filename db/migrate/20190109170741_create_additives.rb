class CreateAdditives < ActiveRecord::Migration[5.2]
  def change
    create_table :additives do |t|
      t.references :bidding, foreign_key: true
      t.date :from
      t.date :to

      t.timestamps
    end
  end
end
