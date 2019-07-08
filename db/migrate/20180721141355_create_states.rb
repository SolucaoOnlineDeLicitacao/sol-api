class CreateStates < ActiveRecord::Migration[5.2]
  def change
    create_table :states do |t|
      t.string :uf
      t.string :name

      t.timestamps
    end
  end
end
