class Unit < ApplicationRecord
  include ::Sortable
  has_many :items

  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }

  def self.default_sort_column
    'units.name'
  end
end
