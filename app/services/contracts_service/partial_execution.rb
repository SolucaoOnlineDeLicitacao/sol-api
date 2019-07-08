module ContractsService
  class PartialExecution
    include TransactionMethods
    include Call::Methods

    def main_method
      completed
    end

    private

    def completed
      return false unless contract.signed?

      execute_or_rollback do
        contract.partial_execution!
        update!
        recalculate_available_quantity!
        update_contract_blockchain!
        notify
      end
    end

    def update!
      contract.update!(contract_params)
    end

    def update_contract_blockchain!
      Blockchain::Contract::Update.call!(contract: contract)
    end

    def recalculate_available_quantity!
      RecalculateQuantityService.call!(covenant: contract.bidding.covenant)
    end

    def notify
      Notifications::Contracts::PartialExecution.call(contract: contract)
    end
  end
end
