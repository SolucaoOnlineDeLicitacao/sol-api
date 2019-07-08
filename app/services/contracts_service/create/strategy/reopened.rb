module ContractsService::Create::Strategy
  class Reopened < Base
    private

    def bidding_lots
      Lot.where(bidding_id: bidding_ids, status: :accepted)
    end

    def bidding_ids
      Bidding.ids_without_contracts(bidding.id)
    end
  end
end
