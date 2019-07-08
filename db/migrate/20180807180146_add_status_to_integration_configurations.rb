class AddStatusToIntegrationConfigurations < ActiveRecord::Migration[5.2]
  def change
    add_column :integration_configurations, :status, :integer
  end
end
