class CreateContracts < ActiveRecord::Migration[5.2]
  def change
    create_table :contracts do |t|
      t.references :proposal, foreign_key: true
      t.bigint :status

      t.timestamps
    end
  end
end
