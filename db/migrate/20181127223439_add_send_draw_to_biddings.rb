class AddSendDrawToBiddings < ActiveRecord::Migration[5.2]
  def change
    add_column :biddings, :send_draw, :datetime
  end
end
