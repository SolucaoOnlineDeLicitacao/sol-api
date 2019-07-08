class AddLogToIntegrationConfigurations < ActiveRecord::Migration[5.2]
  def change
    add_column :integration_configurations, :log, :text
  end
end
