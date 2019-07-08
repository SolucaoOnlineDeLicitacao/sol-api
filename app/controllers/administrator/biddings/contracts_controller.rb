module Administrator
  class Biddings::ContractsController < AdminController
    include BaseContractsController

    load_and_authorize_resource :bidding

    expose :bidding

    private

    def find_contracts
      bidding.contracts
    end
  end
end
