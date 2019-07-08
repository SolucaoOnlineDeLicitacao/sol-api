class CreateDeviceTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :device_tokens do |t|
      t.references :owner, polymorphic: true, index: true
      t.string :body

      t.timestamps
    end
  end
end
