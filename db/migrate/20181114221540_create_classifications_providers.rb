class CreateClassificationsProviders < ActiveRecord::Migration[5.2]
  def change
    create_table :classifications_providers do |t|
      t.bigint :provider_id
      t.bigint :classification_id

      t.timestamps
    end
  end
end
