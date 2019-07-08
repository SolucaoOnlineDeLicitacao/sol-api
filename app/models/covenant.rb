class Covenant < ApplicationRecord
  versionable

  before_validation :ensure_estimated_cost

  attribute :estimated_cost, :money

  include Covenant::Search
  include ::Sortable

  belongs_to :admin
  belongs_to :cooperative
  belongs_to :city

  has_many :groups, -> { order('groups.name') }, dependent: :destroy
  has_many :group_items, through: :groups

  has_many :biddings, dependent: :restrict_with_error

  enum status: %i[waiting running completed canceled]

  validates :number,
            :name,
            :status,
            :signature_date,
            :validity_date,
            :city,
            presence: true

  validates_uniqueness_of :number, scope: :cooperative_id

  delegate :name, to: :cooperative, prefix: true, allow_nil: true
  delegate :name, to: :admin, prefix: true, allow_nil: true
  delegate :text, to: :city, prefix: true, allow_nil: true

  def self.default_sort_column
    'covenants.number'
  end

  private

  def ensure_estimated_cost
    self.estimated_cost = estimated_cost_before_type_cast.to_s.gsub(',', '.').to_f
  end
end
