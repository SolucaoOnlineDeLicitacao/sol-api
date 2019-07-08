module BiddingsService::CancellationRequests
  class Approve
    include Call::Methods
    include TransactionMethods

    attr_accessor :event

    def initialize(*args)
      super
      @event = Events::BiddingCancellationRequest.find(cancellation_request_id)
    end

    def main_method
      update_event_and_cancel_bidding
    end

    private

    def update_event_and_cancel_bidding
      execute_or_rollback do
        update_event!
        cancel_bidding!
      end
    end

    def update_event!
      event.update!(comment_response: comment, status: 'approved')
    end

    def cancel_bidding!
      BiddingsService::Cancel.call!(bidding: bidding)
    end
  end
end
