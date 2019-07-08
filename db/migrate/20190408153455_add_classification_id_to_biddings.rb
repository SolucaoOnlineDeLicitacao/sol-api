class AddClassificationIdToBiddings < ActiveRecord::Migration[5.2]
  def change
    add_column :biddings, :classification_id, :bigint
  end
end
