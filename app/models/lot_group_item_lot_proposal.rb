class LotGroupItemLotProposal < ApplicationRecord
  versionable

  attr_accessor :import_creating

  before_validation :ensure_price
  after_save :ensure_group_itens_prices

  attribute :price, :money

  belongs_to :lot_group_item
  belongs_to :lot_proposal, touch: true

  has_one :group_item, through: :lot_group_item
  has_one :item, through: :group_item
  has_one :provider, through: :lot_proposal
  has_one :proposal, through: :lot_proposal
  has_one :bidding, through: :proposal
  has_one :classification, through: :group_item, source: :classification

  validates :lot_group_item,
            :lot_proposal,
            presence: true

  validates :price, numericality: { greater_than: 0 }

  validates_uniqueness_of :lot_group_item_id, scope: :lot_proposal_id

  private

  def ensure_group_itens_prices
    return if import_creating
    return if lot_proposal&.proposal&.bidding&.kind != 'global'

    lot_group_item_lot_proposals.update_all(price: self.price)
    lot_group_item_lot_proposals.map(&:lot_proposal).map(&:save)
    lot_group_item_lot_proposals.map(&:proposal).map(&:save)
  end

  def lot_group_item_lot_proposals
    @lot_group_item_lot_proposals ||= begin
      LotGroupItemLotProposal.joins(:item, :provider, :bidding).
        where(
          items: { id: lot_group_item&.group_item&.item&.id },
          providers: { id: lot_proposal&.provider&.id },
          biddings: { id: lot_proposal&.proposal&.bidding&.id },
          proposals: { id: lot_proposal&.proposal&.id }).
        where.not(id: self.id)
    end
  end

  def ensure_price
    self.price = price_before_type_cast.to_s.gsub(',', '.').to_f
  end
end
