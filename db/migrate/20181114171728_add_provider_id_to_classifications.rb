class AddProviderIdToClassifications < ActiveRecord::Migration[5.2]
  def change
    add_column :classifications, :provider_id, :bigint
  end
end
