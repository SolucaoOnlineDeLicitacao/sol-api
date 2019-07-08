module EventServices::Contract
  class Refused
    include TransactionMethods
    include Call::Methods

    attr_accessor :contract, :comment, :user, :event

    def initialize(*args)
      super
      @event = Events::ContractRefused.new(attributes)
    end

    private

    def main_method
      execute_or_rollback do
        event.save!
      end
    end

    def attributes
      {
        from: contract.status,
        to: 'refused',
        comment: comment,
        eventable: contract,
        creator: user
      }
    end

  end
end
