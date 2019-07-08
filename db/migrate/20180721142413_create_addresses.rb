class CreateAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses do |t|
      t.references :addressable, polymorphic: true, index: true
      t.decimal :latitude, precision: 11, scale: 8
      t.decimal :longitude, precision: 11, scale: 8
      t.string :address
      t.string :number
      t.string :neighborhood
      t.string :cep
      t.string :complement
      t.string :reference_point
      t.references :city, foreign_key: true

      t.timestamps
    end
  end
end
