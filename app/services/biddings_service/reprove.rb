module BiddingsService
  class Reprove
    include TransactionMethods
    include Call::Methods

    attr_accessor :bidding, :comment, :user, :event

    def initialize(*args)
      super
      @event = Events::BiddingReproved.new(attributes)
    end

    private

    def main_method
      execute_or_rollback do
        event.save!

        updates_bidding_to_review && bidding.reload

        Notifications::Biddings::Reproved.call(bidding)
      end
    end

    def updates_bidding_to_review
      # we just update_attributes instead of draft! because we can get
      # a record invalid from validate_start_date/closing_date (unwanted)
      bidding.update_attributes(status: :draft)
    end

    def attributes
      {
        from: bidding.status,
        to: 'draft',
        comment: comment,
        eventable: bidding,
        creator: user
      }
    end

  end
end
