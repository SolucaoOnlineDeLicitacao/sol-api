module LotGroupItemLotProposalSerializable
  extend ActiveSupport::Concern

  included do
    attributes :id, :price, :_destroy, :lot_group_item
  end

  def price
    object.price.to_f
  end

  def lot_group_item
    ::Coop::LotGroupItemSerializer.new(object.lot_group_item)
  end
end
