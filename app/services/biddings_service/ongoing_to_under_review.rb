module BiddingsService
  class OngoingToUnderReview
    include TransactionMethods
    include Call::Methods

    def main_method
      ongoing_biddings_to_under_review
    end

    private

    def ongoing_biddings_to_under_review
      execute_or_rollback do
        Bidding.ongoing_and_closed_until_today.each do |bidding|
          BiddingsService::UnderReview.call!(bidding: bidding)
        end
      end
    end
  end
end
