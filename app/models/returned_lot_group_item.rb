class ReturnedLotGroupItem < ApplicationRecord
  versionable

  belongs_to :lot_group_item
  belongs_to :contract

  validates :quantity, presence: true, numericality: { 
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: :lot_group_item_quantity 
  }

  private

  def lot_group_item_quantity
    lot_group_item.quantity
  end
end

