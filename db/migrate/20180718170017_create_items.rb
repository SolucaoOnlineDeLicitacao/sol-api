class CreateItems < ActiveRecord::Migration[5.2]
  def change
    create_table :items do |t|
      t.string :title
      t.text :description
      t.integer :unit
      t.references :owner, polymorphic: true, index: true

      t.timestamps
    end
  end
end
