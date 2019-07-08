class AddDeliveryPriceToLotProposals < ActiveRecord::Migration[5.2]
  def change
    add_column :lot_proposals, :delivery_price, :decimal
  end
end
