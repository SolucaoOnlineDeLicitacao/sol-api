class RemoveClassifiableTypeIdFromClassifications < ActiveRecord::Migration[5.2]
  def change
    remove_column :classifications, :classifiable_type, :string
    remove_column :classifications, :classifiable_id, :bigint
  end
end
