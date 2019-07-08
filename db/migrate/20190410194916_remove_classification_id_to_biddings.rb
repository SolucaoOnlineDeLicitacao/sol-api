class RemoveClassificationIdToBiddings < ActiveRecord::Migration[5.2]
  def change
    remove_column :biddings, :classification_id, :bigint
  end
end
