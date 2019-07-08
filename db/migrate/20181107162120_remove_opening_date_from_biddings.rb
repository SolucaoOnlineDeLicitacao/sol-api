class RemoveOpeningDateFromBiddings < ActiveRecord::Migration[5.2]
  def change
    remove_column :biddings, :opening_date
  end
end
