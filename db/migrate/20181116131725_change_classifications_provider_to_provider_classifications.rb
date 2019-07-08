class ChangeClassificationsProviderToProviderClassifications < ActiveRecord::Migration[5.2]
  def change
    rename_table :classifications_providers, :provider_classifications
  end
end
