module BiddingsService
  class DrawToUnderReview
    include TransactionMethods
    include Call::Methods

    def main_method
      drawed_biddings_to_under_review
    end

    private

    def drawed_biddings_to_under_review
      execute_or_rollback do
        Bidding.drawed_until_today.each do |bidding|
          BiddingsService::UnderReview.call!(bidding: bidding)
        end
      end
    end
  end
end
