class RemoveBearerFromIntegrationConfigurations < ActiveRecord::Migration[5.2]
  def change
    remove_column :integration_configurations, :bearer, :string
  end
end
