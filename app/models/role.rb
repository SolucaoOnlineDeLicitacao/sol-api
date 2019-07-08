class Role < ApplicationRecord
  include Role::Search
  include ::Sortable

  validates :title, presence: true

  validates_uniqueness_of :title, case_sensitive: false

  def self.default_sort_column
    'roles.title'
  end

  def text
    title
  end

end
