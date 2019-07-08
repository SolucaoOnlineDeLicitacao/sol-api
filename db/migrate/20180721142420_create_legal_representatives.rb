class CreateLegalRepresentatives < ActiveRecord::Migration[5.2]
  def change
    create_table :legal_representatives do |t|
      t.references :representable, polymorphic: true, index: { name: 'index_legal_reps_on_representable_type_and_representable_id' }
      t.string :name
      t.string :nationality
      t.integer :civil_state
      t.string :rg
      t.string :cpf
      t.date :valid_until

      t.timestamps
    end
  end
end
