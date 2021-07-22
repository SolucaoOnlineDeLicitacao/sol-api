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

        return desert_and_clone_bidding! if proposals_not_draft_or_abandoned.empty?

        under_review_and_notify!
      end
    end

    def global_review!
      if proposals_not_draft_or_abandoned.present?
        lots.map(&:triage!)

        update_proposals(proposals_not_draft_or_abandoned)
      else
        lots.map(&:desert!)
      end
    end

    def common_review!
      lots.find_each do |lot|
        # only sent or draw proposals - cant have abandoned/draft ones
        proposals = lot.proposals.not_draft_or_abandoned

        if proposals.present?
          lot.triage!

          update_proposals(proposals)
        else
          lot.desert!
        end
      end
    end

    def desert_and_clone_bidding!
      bidding.desert!
      bidding.reload
      blockchain_bidding_update!
      BiddingsService::Clone.call!(bidding: bidding)
      generate_minute
    end

    def under_review_and_notify!
      bidding.under_review!
      bidding.reload
      blockchain_bidding_update!
      Notifications::Biddings::UnderReview.call(bidding)
    end

    def blockchain_bidding_update!
      response = Blockchain::Bidding::Update.call(bidding)
      raise BlockchainError unless response.success?
    end

    def update_proposals(proposals)
      # we force all draw proposals to return into sent status
      proposals.draw.map(&:sent!)

      # we have to use only sent proposals
      proposals.sent.lower&.triage!
    end

    def proposals_not_draft_or_abandoned
      @proposals_not_draft_or_abandoned ||= bidding.proposals.not_draft_or_abandoned
    end

    def lots
      @lots ||= bidding.lots
    end

    def generate_minute
      Bidding::Minute::PdfGenerateWorker.perform_async(bidding.id)
    end
  end
end
