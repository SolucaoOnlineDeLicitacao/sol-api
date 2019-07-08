module ContractsService
  class Create::Base
    include TransactionMethods
    include Call::WithExceptionsMethods

    def main_method
      create_contract
    end

    def call_exception
      CreateContractError
    end

    private

    def create_contract
      execute_or_rollback do
        if proposal.present? && contract.present?
          create_contract_at_blockchain!
          notify
        end
      end
    end

    def create_contract_at_blockchain!
      Blockchain::Contract::Create.call!(contract: contract)
    end

    def contract
      @contract ||=
        unscoped_contract.present? ? nil : Contract.create!(attributes_contract)
    end

    def unscoped_contract
      # find only by proposal because another user from the same cooperative can
      # resubmit the form. unscoped because the contract may exists but with deleted_at
      Contract.unscoped.find_by(proposal: proposal)
    end

    def attributes_contract
      {
        proposal: proposal,
        user: user,
        user_signed_at: DateTime.current,
        deadline: deadline
      }
    end

    def notify
      Notifications::Contracts::Created.call(contract: contract)
    end

    # override
    def deadline; end

    # override
    def proposal; end
  end
end
