class AddNewDeliveryFieldsToLots < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :address, :text
    add_column :lots, :deadline, :integer
  end
end
