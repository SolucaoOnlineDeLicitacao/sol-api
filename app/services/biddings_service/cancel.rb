module BiddingsService
  class Cancel
    include TransactionMethods
    include Call::WithExceptionsMethods

    def main_method
      cancel
    end

    def call_exception
      ActiveRecord::RecordInvalid
    end

    private

    def cancel
      execute_or_rollback do
        cancel_bidding!
        bidding.reload
        recalculate_quantity!
        update_bidding_blockchain!
        notify_approved_cancellation_request
      end
    end

    def cancel_bidding!
      bidding.canceled!
      bidding.lots.map(&:canceled!)
    end

    def recalculate_quantity!
      RecalculateQuantityService.call!(covenant: bidding.covenant)
    end

    def update_bidding_blockchain!
      response = Blockchain::Bidding::Update.call(bidding)
      raise BlockchainError unless response.success?
    end

    def notify_approved_cancellation_request
      Notifications::Biddings::CancellationRequests::Approved.call(bidding)
    end
  end
end
