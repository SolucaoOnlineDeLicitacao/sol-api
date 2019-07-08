class RemoveProviderIdOnClassifications < ActiveRecord::Migration[5.2]
  def change
    remove_column :classifications, :provider_id
  end
end
