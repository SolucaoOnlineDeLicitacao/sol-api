module ContractsService
  class Clone::TotalInexecution < Clone::Base
    private

    def change_status_cancel_and_clone
      @change_status_cancel_and_clone ||= begin
        return false unless contract.signed?

        super
      end
    end

    def change_contract_status!
      contract.total_inexecution!
    end

    def notify
      Notifications::Contracts::TotalInexecution.call(contract: contract)
    end
  end
end
