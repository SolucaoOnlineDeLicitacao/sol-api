module EventServices::Proposal
  class Base
    include TransactionMethods
    include Call::WithExceptionsMethods

    attr_accessor :event

    def main_method
      create_event
    end

    def call_exception
      ActiveRecord::RecordInvalid
    end

    def initialize(*args)
      super
      @event = event_class.new(attributes)
    end

    private

    def create_event
      execute_or_rollback do
        if proposal_status
          @event.save!
        end
      end
    end

    def attributes
      {
        from: proposal.status,
        to: to,
        comment: comment,
        eventable: proposal,
        creator: creator
      }
    end

    def proposal_status; end

    def event_class; end

    def to; end

  end
end
