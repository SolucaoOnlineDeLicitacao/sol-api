class LotProposal < ApplicationRecord
  include ::Sortable
  include BiddingModalityValidations

  versionable

  before_validation :ensure_delivery_price
  before_save :update_price_total

  belongs_to :lot, counter_cache: true
  belongs_to :proposal, touch: true
  belongs_to :supplier

  has_one :provider, through: :supplier

  has_many :lot_group_item_lot_proposals, dependent: :destroy
  has_many :lot_group_items, through: :lot
  has_many :group_items, through: :lot_group_items

  validates :lot,
            :proposal,
            :supplier,
            presence: true

  validates :lot_id, uniqueness: { scope: :supplier_id }

  validates :delivery_price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validate :validate_price_total

  accepts_nested_attributes_for :lot_group_item_lot_proposals, allow_destroy: true

  delegate :status, to: :proposal, allow_nil: true, prefix: true

  scope :active_and_orderly, -> do
    joins(:proposal)
      .select("lot_proposals.*, COALESCE(proposals.sent_updated_at, proposals.created_at)")
      .where.not(proposals: { status: [:draft, :abandoned] }).all_lower
  end

  scope :active_and_orderly_with, ->(lot, statuses) do
    joins(:proposal)
      .select("lot_proposals.*, COALESCE(proposals.sent_updated_at, proposals.created_at)")
      .where.not(proposals: { status: statuses })
      .where(lot_proposals: { lot: lot }).all_lower
  end

  scope :read_policy_by, -> (supplier_id) do
    joins(:supplier, lot: :bidding).
      where(
        lots: { biddings: { status: :finnished } }
      ).
      or(
        joins(:supplier, lot: :bidding).
          where(
            lots: { biddings: { status: :under_review, modality: :unrestricted } }
          )
      ).
      or(
        joins(:supplier, lot: :bidding).
          where(suppliers: { id: supplier_id })
      )
  end

  def self.default_sort_column
    'lot_proposals.price_total'
  end

  def self.search(*args)
    all
  end

  def self.all_lower
    price_order.sent_updated_or_created_order
  end

  def self.lower
    all_lower.first
  end

  def status
    proposal_status
  end

  private

  def self.price_order
    order('lot_proposals.price_total')
  end

  def self.sent_updated_or_created_order
    # COALESCE uses the first non null field and here we have to order by the
    # last updated (if exists) or created time
    joins(:proposal).order(Arel.sql("COALESCE(proposals.sent_updated_at, proposals.created_at)"))
  end

  def update_price_total
    self.price_total = recalculated_total

    proposal.sent_updated_at = DateTime.now
    proposal.save
  end

  def recalculated_total
    lot_group_item_lot_proposals.inject([delivery_price.to_f]) do |array, lot_group_item_lot_proposal|
      array << lot_group_item_lot_proposal.price * lot_group_item_lot_proposal.lot_group_item.quantity
    end.reduce(:+)
  end

  def validate_price_total
    if proposal_draw? && recalculated_total > price_total
      errors.add(:price_total, :invalid)
      throw(:abort)
    end
  end

  def proposal_draw?
    proposal.present? && (proposal.draw? || proposal.was_draw?)
  end

  def ensure_delivery_price
    return unless delivery_price_before_type_cast.present?
    self.delivery_price = delivery_price_before_type_cast.to_s.gsub(',', '.').to_f
  end
end
