module Supp
  class ProposalSerializer < ActiveModel::Serializer
    attributes :id, :status, :bidding_id, :bidding_title,
                :price_total, :current, :provider

    has_many :lot_proposals, serializer: Supp::LotProposalSerializer do
      object.lot_proposals.order(:lot_id)
    end

    def current
      object.triage?
    end

    def provider
      object.provider.as_json
    end

    def bidding_id
      object.bidding_id
    end

    def bidding_title
      object.bidding.title
    end

  end
end
