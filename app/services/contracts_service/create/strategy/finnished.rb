module ContractsService::Create::Strategy
  class Finnished < Base
    private

    # desert, failure lot wont have proposals
    def bidding_lots
      bidding.lots.accepted
    end
  end
end
