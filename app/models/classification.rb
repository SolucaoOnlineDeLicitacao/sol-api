class Classification < ApplicationRecord
  include Classification::Search
  include ::Sortable

  versionable

  belongs_to :classification, optional: true
  has_many :classifications, dependent: :destroy

  has_many :items

  has_many :provider_classifications
  has_many :providers, through: :provider_classifications

  validates :name,
            :code,
            presence: true

  validates_uniqueness_of :name, scope: :classification_id, case_sensitive: false
  validates_uniqueness_of :code, case_sensitive: false

  scope :parent_classifications, -> { where(classification_id: nil) }

  def text
    "#{code} - #{name}"
  end

  def self.default_sort_column
    'classifications.name'
  end

  def name
    return self[:name] unless classification.present?

    "#{classification.name} / #{self[:name]}"
  end

  def base_classification
    return self unless classification.present?

    classification.base_classification
  end

  def children_classifications(classification_ids = [])
    return classification_ids unless classifications.present?

    classification_ids << classifications
    classifications.each do |classification|
      classification.children_classifications(classification_ids)
    end
    classification_ids.flatten
  end
end
