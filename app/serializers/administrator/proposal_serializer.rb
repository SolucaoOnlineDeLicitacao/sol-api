module Administrator
  class ProposalSerializer < ActiveModel::Serializer
    include CurrentEventProposable

    has_many :lot_proposals, serializer: Administrator::LotProposalSerializer

    def bidding_id
      object.bidding_id
    end

    def bidding_title
      object.bidding.title
    end

    private

    def event_resource
      object
    end
  end
end
