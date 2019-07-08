module Coop
  class ProposalSerializer < ActiveModel::Serializer
    attributes :id, :status, :bidding_id, :bidding_title,
                :bidding_estimated_cost_total, :price_total, :current, :provider

    has_many :lot_proposals, serializer: Supp::LotProposalSerializer

    def bidding_estimated_cost_total
      bidding.estimated_cost_total
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
      bidding.title
    end

    private

    def bidding
      object.bidding
    end
  end
end
