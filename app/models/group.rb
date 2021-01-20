class Group < ApplicationRecord
  versionable

  belongs_to :covenant
  has_many :group_items, dependent: :destroy, inverse_of: :group

  validates :name, presence: true
  validates_length_of :group_items, minimum: 1

  validates_uniqueness_of :name, scope: :covenant_id

  accepts_nested_attributes_for :group_items, allow_destroy: true
end
