class AddTypeAndIdToClassifications < ActiveRecord::Migration[5.2]
  def change
    add_column :classifications, :classifiable_type, :string
    add_column :classifications, :classifiable_id, :bigint
  end
end
