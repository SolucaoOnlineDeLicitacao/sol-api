class CreateProviders < ActiveRecord::Migration[5.2]
  def change
    create_table :providers do |t|
      t.string :document
      t.string :name
      t.string :type

      t.timestamps
    end
  end
end
