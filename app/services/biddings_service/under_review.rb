module BiddingsService
  class UnderReview
    include TransactionMethods
    include Call::WithExceptionsMethods

    def main_method
      under_review
    end

    def call_exception
      ActiveRecord::RecordInvalid
    end

    private

    def under_review
      execute_or_rollback do
        proposal_draw.call

        return notify if proposal_draw.has_draw

        review
      end
    end

    def proposal_draw
      @proposal_draw ||= ProposalService::Draw.new(bidding)
    end

    def notify
      Notifications::Biddings::Draw.call(bidding: bidding)
    end

    def review
      BiddingsService::Review.call(bidding: bidding)
    end
  end
end
