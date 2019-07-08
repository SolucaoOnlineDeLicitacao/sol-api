module ContractsService::Create::Strategy
  class Base
    include TransactionMethods
    include Call::WithExceptionsMethods

    def main_method
      create!
    end

    def call_exception
      CreateContractError
    end

    private

    def create!
      execute_or_rollback do
        bidding.global? ? create_global_contract! : create_lots_contracts!
      end
    end

    def create_global_contract!
      ContractsService::Create::Global.call!(bidding: bidding, user: user)
    end

    def create_lots_contracts!
      bidding_lots.find_each do |lot|
        ContractsService::Create::Lot.call!(lot: lot, user: user)
      end
    end

    # override
    def bidding_lots; end
  end
end
