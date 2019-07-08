class CreateBiddings < ActiveRecord::Migration[5.2]
  def change
    create_table :biddings do |t|
      t.string :title
      t.text :description
      t.references :covenant, foreign_key: true
      t.integer :kind
      t.integer :status
      t.integer :deadline
      t.string :link
      t.date :start_date
      t.date :closing_date
      t.date :opening_date

      t.timestamps
    end
  end
end
