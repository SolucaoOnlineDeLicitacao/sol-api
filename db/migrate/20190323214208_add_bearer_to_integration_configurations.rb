class AddBearerToIntegrationConfigurations < ActiveRecord::Migration[5.2]
  def change
    add_column :integration_configurations, :bearer, :string
  end
end
