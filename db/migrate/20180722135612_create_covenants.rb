class CreateCovenants < ActiveRecord::Migration[5.2]
  def change
    create_table :covenants do |t|
      t.string :number
      t.integer :status
      t.date :signature_date
      t.date :validity_date
      t.references :user, foreign_key: true
      t.references :cooperative, foreign_key: true

      t.timestamps
    end
  end
end
