module ContractsService
  class Refused < ContractsService::Base

    attr_accessor :event_service

    def initialize(*args)
      super
      @event_service = event_refused_service
    end

    private

    def contract_status!
      contract.refused_by!(refused_by)
    end

    def save_event!
      event_refused_service_call
      raise ActiveRecord::RecordInvalid unless event_valid?
    end

    def notify
      Notifications::Contracts::Refused.call(contract: contract)
    end

    def event_refused_service_call
      event_service.call
    end

    def event_refused_service
      EventServices::Contract::Refused.new(events_params)
    end

    def event_valid?
      event_service.event.valid?
    end

    def events_params
      {
        contract: contract,
        comment: comment,
        user: refused_by
      }
    end
  end
end
