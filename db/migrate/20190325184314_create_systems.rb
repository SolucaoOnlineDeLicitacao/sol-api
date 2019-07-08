class CreateSystems < ActiveRecord::Migration[5.2]
  def change
    create_table :systems do |t|
      t.string :name

      t.timestamps
    end
    System.create(name: 'Sistema')
  end
end
