class LotGroupItem < ApplicationRecord
  versionable

  MINIMUM_QUANTITY_VALUE = 0.freeze

  before_destroy :recount_group_item_quantity, prepend: true
  before_validation :ensure_quantity

  belongs_to :lot, counter_cache: true
  belongs_to :group_item
  has_one :classification, through: :group_item, source: :classification

  has_one :bidding, through: :lot
  has_one :item, through: :group_item

  has_many :lot_group_item_lot_proposals, dependent: :destroy
  has_many :proposals, through: :lot_group_item_lot_proposals, source: :proposal

  validates :quantity, presence: true
  # custom numericality validation since it uses attr_before_type_cast to compair allowing
  # values such as 0.001 to pass its validations (being greater_than 0) but afterwards been rounded to 0.00
  validate :minimum_quantity

  validates :quantity, numericality: { less_than_or_equal_to: :max_quantity }, if: :bidding_draft?

  validates :lot,
            :group_item,
            presence: true

  validates_uniqueness_of :group_item_id, scope: :lot_id

  delegate :draft?, to: :bidding, prefix: true, allow_nil: true

  scope :active, -> { joins(:lot).where.not(lots: { status: [:failure, :desert, :canceled] }) }

  private

  def ensure_quantity
    self.quantity = quantity_before_type_cast.to_s.gsub(',', '.').to_d
  end

  def minimum_quantity
    errors.add(:quantity, :greater_than, count: MINIMUM_QUANTITY_VALUE) unless quantity_greater_than_minimum?
  end

  def quantity_greater_than_minimum?
    quantity.present? && quantity > MINIMUM_QUANTITY_VALUE
  end

  def max_quantity
    new_record? ? group_item.available_quantity.to_d : group_item.available_quantity + quantity_was.to_d
  end

  def recount_group_item_quantity
    RecalculateQuantityService.call!(
      covenant: bidding.covenant,
      lot_group_item: self,
      destroying: true
    )
  end
end
