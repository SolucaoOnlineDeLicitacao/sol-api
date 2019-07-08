class AddLastImportationToIntegrationConfigurations < ActiveRecord::Migration[5.2]
  def change
    add_column :integration_configurations, :last_importation, :datetime
  end
end
