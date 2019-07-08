class AddRenewBiddingIdToBiddings < ActiveRecord::Migration[5.2]
  def change
    add_column :biddings, :renew_bidding_id, :bigint
  end
end
