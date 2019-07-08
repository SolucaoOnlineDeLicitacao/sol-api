module ProvidersService
  class Base
    include Call::Methods
    include TransactionMethods

    attr_accessor :event

    def main_method
      update_provider_and_create_event
    end

    private

    def update_provider_and_create_event
      execute_or_rollback do
        provider.update!(blocked: blocked)
        event_provider_access!
      end
    end

    def event_provider_access!
      @event = event_service.event
      event_service.call!
    end

    def event_service
      @event_service ||=
        service.new(creator: creator, provider: provider, comment: comment)
    end

    # override
    def blocked; end

    # override
    def service; end
  end
end
