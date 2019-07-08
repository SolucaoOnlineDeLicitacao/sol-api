module ContractsService
  class Completed < ContractsService::Base

    private

    def contract_status!
      contract.completed!
    end

    def notify
      Notifications::Contracts::Completed.call(contract: contract)
    end
  end
end
