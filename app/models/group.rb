class Group < ApplicationRecord
  include Group::Search
  include ::Sortable

  versionable

  belongs_to :covenant
  has_many :group_items, dependent: :destroy, inverse_of: :group

  validates :name, presence: true
  validates_length_of :group_items, minimum: 1

  validates_uniqueness_of :name, scope: :covenant_id

  accepts_nested_attributes_for :group_items, allow_destroy: true

  def self.default_sort_column
    'groups.name'
  end
end
