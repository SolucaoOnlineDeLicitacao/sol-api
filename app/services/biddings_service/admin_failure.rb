module BiddingsService
  class AdminFailure
    include Call::WithExceptionsMethods
    include TransactionMethods

    attr_accessor :event

    def main_method
      admin_failure
    end

    def call_exception
      ActiveRecord::RecordInvalid
    end

    private

    def admin_failure
      execute_or_rollback do
        bidding.lots.map(&:failure!)
        recalculate_quantity!
        bidding.failure!
        bidding.reload
        event_bidding_failure!
        update_bidding_at_blockchain!
        notify
      end
    end

    def recalculate_quantity!
      RecalculateQuantityService.call!(covenant: bidding.covenant)
    end

    def event_bidding_failure!
      @event = event_service.event
      event_service.call!
    end

    def update_bidding_at_blockchain!
      response = Blockchain::Bidding::Update.call(bidding)
      raise BlockchainError unless response.success?
    end

    def notify
      Notifications::Biddings::Failure.call(bidding)
    end

    def event_service
      @event_service ||= EventServices::Bidding::Failure.new(
        bidding: bidding,
        comment: comment,
        creator: creator
      )
    end
  end
end
