class Provider < ApplicationRecord
  include Provider::Search
  include ::Sortable
  include ::AddressableConcern

  versionable

  TYPES = %i[individual company].freeze

  has_one :legal_representative, as: :representable

  has_many :suppliers, dependent: :destroy
  has_many :proposals, dependent: :destroy
  has_many :lot_proposals, through: :proposals
  has_many :provider_classifications
  has_many :classifications, through: :provider_classifications
  has_many :invites, dependent: :destroy
  has_many :bidding, through: :invites
  has_many :attachments, as: :attachable, dependent: :destroy
  has_many :contracts, through: :proposals
  has_many :proposal_imports, dependent: :destroy
  has_many :lot_proposal_imports, dependent: :destroy

  has_many :event_provider_accesses, -> { order(created_at: :desc) },
           class_name: 'Events::ProviderAccess',
           foreign_key: :eventable_id, dependent: :destroy

  validates :name,
            :document,
            :type,
            presence: true

  validates_uniqueness_of :name, scope: :document, case_sensitive: false

  validates_length_of :provider_classifications, minimum: 1

  accepts_nested_attributes_for :legal_representative
  accepts_nested_attributes_for :provider_classifications, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :attachments, allow_destroy: true
  accepts_nested_attributes_for :suppliers

  scope :all_without_users, -> do
    left_outer_joins(:suppliers).where(suppliers: { id: nil })
  end

  scope :by_classification_ids, ->(class_ids) do
    includes(:classifications).where(classifications: { id: class_ids })
  end

  scope :with_suppliers, -> { joins(:suppliers) }

  scope :by_classification, -> (classification_id) do
    joins(:classifications).where(classifications: { id: classification_id }).distinct(:id)
  end

  scope :with_access, -> { where(blocked: false) }

  def self.types
    TYPES
  end

  def self.default_sort_column
    'providers.name'
  end

  def text
    "#{name} / #{document}"
  end
end
