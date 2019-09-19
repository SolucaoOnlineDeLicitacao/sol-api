class ChangeCodeTypeFromItems < ActiveRecord::Migration[5.2]
  def change
    change_column :items, :code, :bigint
  end
end
