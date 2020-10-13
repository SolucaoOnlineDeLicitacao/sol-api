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
    errors.add(
      :lot_group_items, 
      :in_use, 
      title: title, 
      code: code, 
      changes: changes_messages) if locked_for_modification?
  end

  private

  def locked_for_modification?
    lot_group_items_in_use? && changed_forbidden_attributes?
  end

  def changed_forbidden_attributes?
    title_changed_insensitive? || description_changed_insensitive? || unit_id_changed?
  end

  def lot_group_items_in_use?
    bidding_by_lot_group_items.not_draft.any?
  end

  def notify_users
    return unless changed_forbidden_attributes?
    
    bidding_by_lot_group_items.draft.each do |bidding|
      Notifications::Biddings::Items::Cooperative.call(bidding, self)
    end
  end

  def bidding_by_lot_group_items
    Bidding.by_lot_group_items(lot_group_items.ids)
  end

  def unit_name_by_id(id)
    Unit.find(id).name
  end

  def title_changed_insensitive?
    title.to_s.downcase != title_was.to_s.downcase
  end

  def description_changed_insensitive?
    description.to_s.downcase != description_was.to_s.downcase
  end

  def changes_messages
    message = ""

    if title_changed_insensitive?
      message << " Título mudou de '#{title_was}' para '#{title}'"
    end

    if description_changed_insensitive?
      message << " Descrição mudou de '#{description_was}' para '#{description}'"
    end

    if unit_id_changed?
      message << " Unidade de Medida mudou de '#{unit_name_by_id(unit_id_was)}' para '#{unit_name_by_id(unit_id)}'"
    end

    message
  end
end
