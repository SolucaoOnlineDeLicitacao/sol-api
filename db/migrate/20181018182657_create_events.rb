class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.references :eventable, polymorphic: true
      t.references :creator, polymorphic: true
      t.jsonb :data, default: {}, null: false
      t.string :type, null: false

      t.timestamps
    end
  end
end
