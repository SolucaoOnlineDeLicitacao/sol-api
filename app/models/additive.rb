class Additive < ApplicationRecord
  versionable

  belongs_to :bidding

  validates :from, :to, presence: true
  validate :retroactive_date

  def retroactive_date
    errors.add(:to, :invalid) if to && bidding && to <= bidding.closing_date
  end
end
