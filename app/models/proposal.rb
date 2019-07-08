class Proposal < ApplicationRecord
  include ::Sortable
  include BiddingModalityValidations

  versionable

  attr_accessor :import_creating

  before_destroy do
    imports_running
    throw(:abort) if errors.present?
  end

  after_commit :update_price_total

  enum status: {
    draft: 0, sent: 1, triage: 2, coop_refused: 3, refused: 4,
    coop_accepted: 5, accepted: 6, failure: 7, draw: 8, abandoned: 9
  }

  belongs_to :bidding
  belongs_to :provider

  has_one :contract, -> { unscope(where: :deleted_at) }, dependent: :nullify

  has_many :lot_proposals, dependent: :destroy
  has_many :lot_group_item_lot_proposals, through: :lot_proposals
  has_many :lots, -> { sorted }, through: :bidding
  has_many :classifications, through: :lot_group_item_lot_proposals, source: :classification
  has_many :current_lots, through: :lot_proposals, source: :lot
  has_many :concurrent_proposals, through: :current_lots, source: :proposals

  has_many :event_proposal_status_changes,
            class_name: 'Events::ProposalStatusChange', foreign_key: :eventable_id,
            dependent: :destroy

  has_many :event_cancel_proposal_refuseds,
            class_name: 'Events::CancelProposalRefused', foreign_key: :eventable_id,
            dependent: :destroy

  has_many :event_cancel_proposal_accepteds,
            class_name: 'Events::CancelProposalAccepted', foreign_key: :eventable_id,
            dependent: :destroy

  validates :bidding,
            :provider,
            :status,
            presence: true

  validates_length_of :lot_proposals, minimum: 1, unless: :draft_or_abandoned?

  validate :imports_running

  accepts_nested_attributes_for :lot_proposals

  scope :active_and_orderly, -> do
    select("proposals.*, COALESCE(proposals.sent_updated_at, proposals.created_at)").
      not_draft_or_abandoned.all_lower
  end

  scope :accepteds_without_contracts, -> do
    left_outer_joins(:contract).where(contracts: { proposal_id: nil }).accepted
  end

  scope :read_policy_by, -> (supplier_id) do
    joins(:bidding, provider: :suppliers).
      where(
        biddings: { status: :finnished }
      ).
      or(
        joins(:bidding, provider: :suppliers).
          where(
            biddings: { status: :under_review, modality: :unrestricted }
          )
      ).
      or(
        joins(:bidding, provider: :suppliers).
          where(suppliers: { id: supplier_id })
      )
  end

  scope :not_draft, -> do
    where.not(status: :draft)
  end

  def self.all_lower
    price_order.sent_updated_or_created_order
  end

  def self.lower
    all_lower.first
  end

  def self.search(*args)
    all
  end

  def self.default_sort_column
    'proposals.price_total'
  end

  def self.next_proposal
    where(status: :sent)&.lower
  end

  def self.not_failure
    where.not(status: :failure)
  end

  def self.not_draft_or_abandoned
    where.not(status: [ :draft, :abandoned ])
  end

  def lots_name
    lot_proposals.map(&:lot).map(&:name).to_sentence
  end

  def concurrent_not_failure
    concurrent_proposals.not_failure
  end

  def was_draft?
    previous_version_status == 'draft'
  end

  def was_draw?
    previous_version_status == 'draw'
  end

  def previous_version_status
    versions.reorder(:id)[-2]&.reify&.status
  end

  private

  def draft_or_abandoned?
    draft? || abandoned?
  end

  def self.price_order
    order('proposals.price_total')
  end

  def self.sent_updated_or_created_order
    # COALESCE uses the first non null field and here we have to order by the
    # last updated (if exists) or created time
    order(Arel.sql("COALESCE(proposals.sent_updated_at, proposals.created_at)"))
  end

  def update_price_total
    total = lot_proposals.sum(:price_total)
    update_column(:price_total, total) if persisted?
  end

  def imports_running
    if not_importing_and_bidding_proposals?
      errors.add(:bidding, :already_importing)
    end
  end

  def not_importing_and_bidding_proposals?
    !import_creating && importing_bidding_proposals.any?
  end

  def importing_bidding_proposals
    return [] if bidding.blank?

    proposal_imports + lot_proposal_imports
  end

  def proposal_imports
    bidding_imports(:proposal_imports)
  end

  def lot_proposal_imports
    bidding_imports(:lot_proposal_imports)
  end

  def bidding_imports(import_type)
    bidding.send(import_type).
      where(provider: provider, status: [:waiting, :processing])
  end
end
