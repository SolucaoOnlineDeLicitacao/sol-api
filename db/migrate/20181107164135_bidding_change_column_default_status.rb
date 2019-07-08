class BiddingChangeColumnDefaultStatus < ActiveRecord::Migration[5.2]
  def change
    change_column_default :biddings, :status, 0
  end
end
