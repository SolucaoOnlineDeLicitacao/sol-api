module BiddingsService
  class CancellationRequest
    include Call::Methods
    include TransactionMethods

    attr_accessor :event

    def initialize(*args)
      super
      @event = Events::BiddingCancellationRequest.new(event_params)
    end

    def main_method
      create_event_and_notify
    end

    private

    def create_event_and_notify
      return false if bidding.draft?

      execute_or_rollback do
        event.save!
        bidding.suspended! if bidding.approved?
        bidding.reload
        notify
      end
    end

    def notify
      Notifications::Biddings::CancellationRequests::New.call(bidding)
    end

    def event_params
      {
        from: bidding.status,
        to: 'canceled',
        comment: comment,
        eventable: bidding,
        creator: creator
      }
    end
  end
end
