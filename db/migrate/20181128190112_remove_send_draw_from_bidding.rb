class RemoveSendDrawFromBidding < ActiveRecord::Migration[5.2]
  def change
    remove_column :biddings, :send_draw, :datetime
  end
end
