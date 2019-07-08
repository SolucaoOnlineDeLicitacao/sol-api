class CreateIntegrationConfigurations < ActiveRecord::Migration[5.2]
  def change
    create_table :integration_configurations do |t|
      t.string :type
      t.string :endpoint_url
      t.string :token
      t.string :schedule

      t.timestamps
    end
  end
end
