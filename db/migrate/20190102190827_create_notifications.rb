class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.references :receivable, polymorphic: true, index: true
      t.references :sendable, polymorphic: true, index: true
      t.references :notifiable, polymorphic: true, index: true
      t.jsonb :data, default: {}, null: false
      t.datetime :read_at
      t.string :action, index: true

      t.timestamps
    end
  end
end
