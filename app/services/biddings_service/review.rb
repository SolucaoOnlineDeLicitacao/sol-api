module BiddingsService
  class Review
    include TransactionMethods
    include Call::Methods

    def main_method
      change_bidding_to_under_review
    end

    private

    def change_bidding_to_under_review
      execute_or_rollback do
        if bidding.global?
          global_review!
        else
          common_review!
        end

        bidding.under_review!
        bidding.reload

        raise BlockchainError unless blockchain_bidding_update.success?

        Notifications::Biddings::UnderReview.call(bidding)
      end
    end

    def global_review!
      if global_proposals.present?
        lots.map(&:triage!)

        update_proposals(global_proposals)
      else
        lots.map(&:desert!)
      end
    end

    def common_review!
      lots.find_each do |lot|
        # only sent or draw proposals - cant have abandoned/draft ones
        proposals = lot.proposals.where.not(status: [:draft, :abandoned])

        if proposals.present?
          lot.triage!

          update_proposals(proposals)
        else
          lot.desert!
        end
      end
    end

    def blockchain_bidding_update
      Blockchain::Bidding::Update.call(bidding)
    end

    def update_proposals(proposals)
      # we force all draw proposals to return into sent status
      proposals.draw.map(&:sent!)

      # we have to use only sent proposals
      proposals.sent.lower&.triage!
    end

    def global_proposals
      # only sent or draw proposals - cant have abandoned/draft ones
      @global_proposals ||= bidding.proposals.where.not(status: [:draft, :abandoned])
    end

    def lots
      @lots ||= bidding.lots
    end
  end
end
