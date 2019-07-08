module EventServices::Provider
  class Base
    include TransactionMethods
    include Call::WithExceptionsMethods

    attr_accessor :event

    def initialize(*args)
      super
      @event = Events::ProviderAccess.new(attributes)
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
        blocked: blocked,
        comment: comment,
        eventable: provider,
        creator: creator
      }
    end

    # override
    def blocked; end
  end
end
