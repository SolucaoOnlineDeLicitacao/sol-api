class ChangeRenewBiddingIdToParentIdOnBidding < ActiveRecord::Migration[5.2]
  def change
    rename_column :biddings, :renew_bidding_id, :parent_id
  end
end
