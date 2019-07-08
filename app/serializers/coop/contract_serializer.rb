module Coop
  class ContractSerializer < ActiveModel::Serializer
    include BaseContractSerializer

    attributes :proposals_count

    def proposals_count
      proposals.count
    end

    private

    def proposals
      bidding.proposals_not_draft_or_abandoned
    end

    def global?
      bidding.global?
    end

    def bidding
      object.bidding
    end
    
  end
end
