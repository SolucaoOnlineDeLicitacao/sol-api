module Supp
  class LotProposalSerializer < ActiveModel::Serializer
    attributes :id, :proposal_id, :status, :bidding_id, :bidding_title,
                :price_total, :delivery_price, :current, :lot, :provider

    has_many :lot_group_item_lot_proposals, serializer: Supp::LotGroupItemLotProposalSerializer

    def lot
      Supp::LotSerializer.new(object.lot)
    end

    def proposal
      object.proposal
    end

    def proposal_id
      proposal.id
    end

    def current
      proposal.triage?
    end

    def delivery_price
      ('%.2f' % object.delivery_price).to_s.gsub('.', ',')
    end

    def provider
      proposal.provider.as_json
    end

    def bidding_id
      object.lot.bidding_id
    end

    def bidding_title
      object.lot.bidding.title
    end
  end
end
