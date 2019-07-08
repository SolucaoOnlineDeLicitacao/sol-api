class AddCodeToClassification < ActiveRecord::Migration[5.2]
  def change
    add_column :classifications, :code, :integer
  end
end
