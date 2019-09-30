class Item < ApplicationRecord
  include Item::Search
  include ::Sortable

  versionable

  attr_accessor :children_classification_id

  after_update_commit :notify_users

  before_destroy do
    throw(:abort) if lot_group_items_in_use?
    true
  end

  belongs_to :owner, polymorphic: true
  belongs_to :classification
  belongs_to :unit

  has_many :group_items, dependent: :destroy
  has_many :lot_group_items, through: :group_items

  validates :title,
            :description,
            :owner,
            :code,
            presence: true

  validates_uniqueness_of :title, scope: :code, case_sensitive: false
  validates_uniqueness_of :code

  validate :item_modification

  delegate :name, to: :owner, prefix: true, allow_nil: true
  delegate :name, to: :classification, prefix: true, allow_nil: true
  delegate :name, to: :unit, prefix: true, allow_nil: true

  def self.default_sort_column
    'items.title'
  end

  def text
    "#{classification_name} / #{title} - #{description}"
  end

  def item_modification
    errors.add(:lot_group_items, :in_use) if locked_for_modification?
  end

  private

  def locked_for_modification?
    lot_group_items_in_use? && changed_forbidden_attributes?
  end

  def changed_forbidden_attributes?
    title_changed? || description_changed? || unit_id_changed?
  end

  def lot_group_items_in_use?
    bidding_by_lot_group_items.not_draft.any?
  end

  def notify_users
    bidding_by_lot_group_items.draft.each do |bidding|
      Notifications::Biddings::Items::Cooperative.call(bidding, self)
    end
  end

  def bidding_by_lot_group_items
    Bidding.by_lot_group_items(lot_group_items.ids)
  end
end
