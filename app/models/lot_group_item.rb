class LotGroupItem < ApplicationRecord
  versionable

  before_destroy :recount_group_item_quantity, prepend: true

  belongs_to :lot, counter_cache: true
  belongs_to :group_item
  has_one :classification, through: :group_item, source: :classification

  has_one :bidding, through: :lot
  has_one :item, through: :group_item

  has_many :lot_group_item_lot_proposals, dependent: :destroy
  has_many :proposals, through: :lot_group_item_lot_proposals, source: :proposal

  validates :quantity, presence: true, numericality: { greater_than: 0 }

  validates :quantity, numericality: { less_than_or_equal_to: :max_quantity }, if: :bidding_draft?

  validates :lot,
            :group_item,
            presence: true

  validates_uniqueness_of :group_item_id, scope: :lot_id

  delegate :draft?, to: :bidding, prefix: true, allow_nil: true

  scope :active, -> { joins(:lot).where.not(lots: { status: [:failure, :desert, :canceled] }) }

  private

  def max_quantity
    new_record? ? group_item.available_quantity : group_item.available_quantity + quantity_was.to_i
  end

  def recount_group_item_quantity
    RecalculateQuantityService.call!(
      covenant: bidding.covenant,
      lot_group_item: self,
      destroying: true
    )
  end
end
