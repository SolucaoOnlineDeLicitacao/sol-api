class AddLastSuccessAtToIntegrationConfigurations < ActiveRecord::Migration[5.2]
  def change
    add_column :integration_configurations, :last_success_at, :datetime
  end
end
