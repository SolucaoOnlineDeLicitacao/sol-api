module ContractsService
  class Base
    include TransactionMethods
    include Call::WithExceptionsMethods

    def main_method
      status!
    end

    def call_exception
      ActiveRecord::RecordInvalid
    end

    private

    def status!
      execute_or_rollback do
        contract_status!
        save_event!
        update_contract_blockchain!
        notify
      end
    end

    def update_contract_blockchain!
      Blockchain::Contract::Update.call!(contract: contract)
    end

    # create an event
    def save_event!; end

    # override for notification
    def notify; end
  end
end
