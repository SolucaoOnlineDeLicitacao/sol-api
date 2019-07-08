class CreateUnits < ActiveRecord::Migration[5.2]
  def change
    create_table :units do |t|
      t.belongs_to :item, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
