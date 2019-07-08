module BiddingsService
  class Ongoing
    include TransactionMethods
    include Call::WithExceptionsMethods

    def main_method
      change_bidding_to_ongoing
    end

    def call_exception
      ActiveRecord::RecordInvalid
    end

    private

    def change_bidding_to_ongoing
      execute_or_rollback do
        bidding.ongoing!
        bidding.reload

        raise BlockchainError unless blockchain_bidding_update.success?

        Notifications::Biddings::Ongoing.call(bidding)
      end
    end

    def blockchain_bidding_update
      Blockchain::Bidding::Update.call(bidding)
    end
  end
end
