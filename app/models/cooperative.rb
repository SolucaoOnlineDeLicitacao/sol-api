class Cooperative < ApplicationRecord
  include Cooperative::Search
  include ::Sortable
  include ::AddressableConcern

  versionable

  has_one :legal_representative, as: :representable, dependent: :destroy

  has_many :users, dependent: :destroy
  has_many :covenants, dependent: :restrict_with_error
  has_many :biddings, through: :covenants
  has_many :proposals, through: :biddings
  has_many :contracts, through: :proposals

  validates :name,
            :cnpj,
            :address,
            :legal_representative,
            presence: true

  validates :cnpj, cnpj: true

  # validates_uniqueness_of :cnpj
  validates_uniqueness_of :name, scope: :cnpj, case_sensitive: false

  delegate :city_name, :state_name, to: :address, prefix: true, allow_nil: true

  accepts_nested_attributes_for :legal_representative

  def self.default_sort_column
    'cooperatives.name'
  end

  def text
    "#{name} / #{cnpj}"
  end
end
