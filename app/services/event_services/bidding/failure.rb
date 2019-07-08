module EventServices::Bidding
  class Failure
    include TransactionMethods
    include Call::WithExceptionsMethods

    attr_accessor :bidding, :comment, :creator, :event

    def initialize(*args)
      super
      @event = Events::BiddingFailure.new(attributes)
    end

    def main_method
      create_event
    end

    def call_exception
      ActiveRecord::RecordInvalid
    end

    private

    def create_event
      execute_or_rollback do
        event.save!
      end
    end

    def attributes
      {
        from: bidding.status,
        to: 'failure',
        comment: comment,
        eventable: bidding,
        creator: creator
      }
    end
  end
end
