class Lot < ApplicationRecord
  include Lot::Search
  include ::Sortable

  versionable

  mount_uploader :lot_proposal_import_file, FileUploader

  enum status: { draft: 0, waiting: 1, triage: 2, accepted: 3, failure: 4, desert: 5, canceled: 6 }

  before_create :update_position
  after_save :update_estimated_cost_total

  after_destroy :update_position_bidding_lots

  belongs_to :bidding

  has_many :lot_group_items, dependent: :destroy
  has_many :group_items, through: :lot_group_items

  has_many :lot_proposals, dependent: :destroy
  has_many :proposals, through: :lot_proposals
  has_many :lot_proposal_imports, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy

  validates :name,
            :bidding,
            presence: true

  validates_uniqueness_of :name, scope: :bidding_id, case_sensitive: false

  validates_length_of :lot_group_items, minimum: 1

  validate :unitary_lot_group_items_count

  accepts_nested_attributes_for :lot_group_items, allow_destroy: true
  accepts_nested_attributes_for :attachments, allow_destroy: true

  def self.default_sort_column
    'lots.position'
  end

  def proposals_not_draft_or_abandoned
    proposals.not_draft_or_abandoned
  end

  private

  def update_position
    self.position = bidding.lots.count + 1
  end

  def update_estimated_cost_total
    self.update_column(:estimated_cost_total, calculate_estimated_cost_total)
  end

  def calculate_estimated_cost_total
    lot_group_items.joins(:group_item).sum(estimated_cost_total_sum)
  end

  def estimated_cost_total_sum
    'group_items.estimated_cost*lot_group_items.quantity'
  end

  def update_position_bidding_lots
    bidding.reload.lots.order(:id).each_with_index do |lot, index|
      lot.update_column(:position, index + 1)
    end
  end

  def unitary_lot_group_items_count
    return unless bidding.present? && bidding.unitary?

    active_lot_group_items = lot_group_items.reject(&:marked_for_destruction?)

    errors.add(:lot_group_items, :too_many) if active_lot_group_items.size > 1
  end

end
