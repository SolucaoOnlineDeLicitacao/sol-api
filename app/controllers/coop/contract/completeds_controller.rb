module Coop
  class Contract::CompletedsController < CoopController
    include CrudController

    load_and_authorize_resource :contract, parent: false

    expose :contract

    before_action :set_paper_trail_whodunnit

    private

    def resource
      contract
    end

    def updated?
      ContractsService::Completed.call(contract: contract)
    end
  end
end
