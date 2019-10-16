class Bidding < ApplicationRecord
  include Bidding::Search
  include ::Sortable

  versionable

  mount_uploader :proposal_import_file, FileUploader

  attr_accessor :skip_cloning_validations, :force_failure

  before_validation :update_draw_at
  before_create :update_position
  after_create :update_title, :update_code
  after_save :update_estimated_cost_total

  attribute :value, :money

  enum kind: { unitary: 1, lot: 2, global: 3 }
  enum status: { draft: 0, waiting: 1, approved: 2, ongoing: 3, draw: 4,
                 under_review: 5, finnished: 6, canceled: 7, suspended: 8,
                 failure: 9, reopened: 10, desert: 11 }
  enum modality: { unrestricted: 0, open_invite: 1, closed_invite: 2 }

  belongs_to :covenant

  belongs_to :reopen_reason_contract, class_name: 'Contract',
                                      foreign_key: :reopen_reason_contract_id,
                                      optional: true

  belongs_to :merged_minute_document, class_name: 'Document',
                                      foreign_key: :merged_minute_document_id,
                                      optional: true

  has_and_belongs_to_many :minute_documents, class_name: 'Document',
                                             foreign_key: :bidding_id,
                                             association_foreign_key: :minute_document_id,
                                             join_table: 'biddings_and_minute_documents'

  belongs_to :edict_document, class_name: 'Document',
                              foreign_key: :edict_document_id,
                              optional: true
  belongs_to :classification

  has_one :cooperative, through: :covenant
  has_one :admin, through: :covenant

  has_many :lots, -> { sorted }, dependent: :destroy
  has_many :lot_group_items, through: :lots
  has_many :lot_proposals, through: :lots
  has_many :proposals, dependent: :destroy
  has_many :invites, dependent: :destroy
  has_many :providers, through: :invites
  has_many :group_items, through: :lot_group_items
  has_many :contracts, through: :proposals
  has_many :additives, dependent: :destroy
  has_many :proposal_imports, dependent: :destroy
  has_many :lot_proposal_imports, dependent: :destroy

  has_many :event_cancellation_requests,
           class_name: 'Events::BiddingCancellationRequest',
           foreign_key: :eventable_id, dependent: :destroy

  has_many :event_bidding_reproveds,
           class_name: 'Events::BiddingReproved', foreign_key: :eventable_id,
           dependent: :destroy

  has_many :event_bidding_failures,
           class_name: 'Events::BiddingFailure', foreign_key: :eventable_id,
           dependent: :destroy

  accepts_nested_attributes_for :invites, allow_destroy: true

  validates :covenant,
            :description,
            :kind,
            :modality,
            :status,
            :deadline,
            :start_date,
            :closing_date,
            :draw_end_days,
            :draw_at,
            presence: true

  validate :validate_start_date, unless: :skip_validate_dates?
  validate :validate_closing_date, unless: :skip_validate_dates?
  validate :validate_invites, if: :needs_invites?
  validate :validate_fully_failed_lots, if: :failure?

  validates_numericality_of :deadline, only_integer: true, greater_than: 0

  validates_length_of :lots, minimum: 1, unless: :draft?

  scope :by_lot_group_items, -> (lot_group_item_ids) do
    joins(:lot_group_items).where(lot_group_items: { id: lot_group_item_ids })
  end
  scope :by_cooperative, -> (cooperative_id) do
    joins(:cooperative).where(cooperatives: { id: cooperative_id })
  end
  scope :not_draft, -> { where.not(status: :draft) }
  scope :approved_and_started_until_today, -> { approved.where("start_date <= :date", date: Date.current) }
  scope :drawed_until_today, -> { draw.where("draw_at <= :date", date: Date.current) }
  scope :ongoing_and_closed_until_today, -> { ongoing.where("closing_date <= :date", date: Date.current) }
  scope :in_progress, -> { where.not(status: [:draw, :canceled, :failure]) }

  delegate :name, to: :classification, prefix: true, allow_nil: true

  def self.default_sort_column
    'biddings.created_at'
  end

  def self.default_sort_direction
    :desc
  end

  def self.by_provider(provider)
    # licitações abertas e convite aberto ATIVAS
    # OU licitações convite fechado COM convite aprovado ATIVAS
    left_outer_joins(:invites).where(modality: [:unrestricted, :open_invite]).active
    .or(
      left_outer_joins(:invites).where(
        modality: :closed_invite, invites: { status: :approved, provider: provider }
      ).active
    )
  end

  def self.active
    where.not(status: [:draft, :waiting, :approved])
  end

  def self.in_progress_count
    where(status: %i[ongoing draw under_review]).count
  end

  def self.ids_without_contracts(bidding_id)
    left_outer_joins(:contracts).
      where(id: bidding_id, contracts: { proposal_id: nil }).ids.uniq
  end

  def proposals_for_retry_by_lot(lot_ids)
    proposals.
      joins(:lot_proposals).
      where(
        status: %i[sent accepted refused],
        lot_proposals: { lot_id: lot_ids }
      )
  end

  def proposals_not_draft_or_abandoned
    proposals.not_draft_or_abandoned
  end

  def fully_failed_lots?
    lots.all?(&:failure?)
  end

  def update_title
    update_column(:title, "#{id}/#{Date.today.year}")
  end

  def update_code
    update_column(:code, identifier_code)
  end

  def update_draw_at
    return unless closing_date.present?

    self.draw_at = closing_date + draw_end_days.to_i
  end

  def skip_cloning_validations!
    @skip_cloning_validations = true
  end

  def force_failure!
    @force_failure = true
  end

  private

  def update_estimated_cost_total
    self.update_column(:estimated_cost_total, lots.sum(:estimated_cost_total))
  end

  def update_position
    self.position = covenant.biddings.count + 1
  end

  def covenant_number
    covenant.number.split('/').last
  end

  def identifier_code
    "#{covenant_number}-#{position_right}-#{Date.current.year}"
  end

  def position_right
    position.to_s.rjust(3, '0')
  end

  def skip_validate_dates?
    skip_cloning_validations || !draft?
  end

  def needs_invites?
    ! (draft? || unrestricted?)
  end

  def validate_start_date
    return unless start_date.present? && closing_date.present?
    errors.add(:start_date, :invalid) if closing_date_before_start_date? || future_start_date?
  end

  def validate_closing_date
    return unless closing_date.present?
    errors.add(:closing_date, :invalid) if future_closing_date?
  end

  def validate_invites
    errors.add(:invites, :invites_closed_invite) if invites.empty?
  end

  def validate_fully_failed_lots
    errors.add(:lots, :fully_failed_lots) if !fully_failed_lots? && force_failure?
  end

  def force_failure?
    force_failure == true
  end

  def closing_date_before_start_date?
    start_date > closing_date
  end

  def future_closing_date?
    closing_date <= Date.today
  end

  def future_start_date?
    start_date <= Date.today
  end
end
