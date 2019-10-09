module BiddingsService
  class ApprovedToOngoing
    include TransactionMethods
    include Call::Methods

    def main_method
      approved_biddings_to_ongoing
    end

    private

    def approved_biddings_to_ongoing
      execute_or_rollback do
        Bidding.approved_and_started_until_today.each do |bidding|
          BiddingsService::Ongoing.call!(bidding: bidding)
        end
      end
    end
  end
end
