class City < ApplicationRecord
  include City::Search
  include ::Sortable

  belongs_to :state

  validates :name,
            :code,
            presence: true

  validates_uniqueness_of :code, case_sensitive: false

  def self.default_sort_column
    'cities.name'
  end

  def text
    "#{name} / #{state.uf}"
  end

end
