module ContractsService
  class Proposals::TotalInexecution < Proposals::Base
    private

    def change_status_fail_and_retry
      return false unless contract.signed?

      super
    end

    def change_contract_status!
      contract.total_inexecution!
    end

    def notify
      Notifications::Contracts::TotalInexecution.call(contract: contract)
    end
  end
end
