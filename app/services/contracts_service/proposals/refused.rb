module ContractsService
  class Proposals::Refused < Proposals::Base
    private

    def update_deleted_at!
      contract.update!(deleted_at: DateTime.current)
    end

    def change_contract_status!
      contract.refused!
    end
  end
end
