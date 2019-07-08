module ContractsService
  class Create::Global < Create::Base
    private

    def deadline
      @deadline ||=
        ContractsService::CalculateDeadline.call(lots: bidding.lots.accepted)
    end

    def proposal
      @proposal ||= bidding.proposals&.accepted.first
    end
  end
end