class CreateCooperatives < ActiveRecord::Migration[5.2]
  def change
    create_table :cooperatives do |t|
      t.text :name
      t.string :cnpj

      t.timestamps
    end
  end
end
