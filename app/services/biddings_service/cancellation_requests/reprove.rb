module BiddingsService::CancellationRequests
  class Reprove
    include Call::Methods
    include TransactionMethods

    attr_accessor :event

    def initialize(*args)
      super
      @event = Events::BiddingCancellationRequest.find(cancellation_request_id)
    end

    def main_method
      update_event_and_notify
    end

    private

    def update_event_and_notify
      execute_or_rollback do
        update_event!
        change_bidding_and_lots_to_draft! if event_from_approved?
        notify
      end
    end

    def update_event!
      event.update!(comment_response: comment, status: 'reproved')
    end

    def event_from_approved?
      event.from == 'approved'
    end

    def change_bidding_and_lots_to_draft!
      bidding.draft!
      bidding.lots.map(&:draft!)
      update_bidding_at_blockchain!
    end

    def update_bidding_at_blockchain!
      response = Blockchain::Bidding::Update.call(bidding)
      raise BlockchainError unless response.success?
    end

    def notify
      Notifications::Biddings::CancellationRequests::Reproved.call(bidding)
    end
  end
end
