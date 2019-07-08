class CreateCities < ActiveRecord::Migration[5.2]
  def change
    create_table :cities do |t|
      t.integer :code
      t.string :name
      t.references :state, foreign_key: true

      t.timestamps
    end
  end
end
