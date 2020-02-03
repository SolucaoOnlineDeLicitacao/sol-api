class ReturnedLotGroupItem < ApplicationRecord
  versionable

  MINIMUM_QUANTITY_VALUE = 0.freeze

  before_validation :ensure_quantity

  belongs_to :lot_group_item
  belongs_to :contract

  validates :quantity, presence: true
  # custom numericality validation since it uses attr_before_type_cast to compair allowing
  # values such as 0.001 to pass its validations (being greater_than 0) but afterwards been rounded to 0.00 
  validate :minimum_quantity

  private

  def ensure_quantity
    return unless quantity_before_type_cast.present?
    self.quantity = quantity_before_type_cast.to_s.gsub(',', '.').to_f
  end

  def minimum_quantity
    return unless quantity.present?
    
    errors.add(:quantity, :greater_than_or_equal_to, count: MINIMUM_QUANTITY_VALUE) if quantity_less_than_minimum?
    errors.add(:quantity, :less_than_or_equal_to, count: lot_group_item_quantity) if quantity_bigger_than_lot_group_item_quantity?
  end

  def quantity_less_than_minimum?
    quantity < MINIMUM_QUANTITY_VALUE
  end

  def quantity_bigger_than_lot_group_item_quantity?
    lot_group_item && quantity > lot_group_item_quantity
  end

  def lot_group_item_quantity
    lot_group_item&.quantity
  end
end

