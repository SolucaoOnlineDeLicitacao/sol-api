module ContractsService
  class Create::Lot < Create::Base
    private

    def deadline
      @deadline ||=
        ContractsService::CalculateDeadline.call(lots: [lot])
    end

    def proposal
      @proposal ||= lot.proposals&.accepted.first
    end
  end
end