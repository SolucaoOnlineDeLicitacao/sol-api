module ContractsService
  class Clone::Refused < Clone::Base
    private

    def change_status_cancel_and_clone
      @change_status_cancel_and_clone ||= super
    end

    def change_contract_status!
      contract.refused!
    end
  end
end
