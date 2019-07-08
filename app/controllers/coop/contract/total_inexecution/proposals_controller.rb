module Coop::Contract
  class TotalInexecution::ProposalsController < CoopController
    include CrudController

    load_and_authorize_resource :contract, parent: false

    expose :contract

    before_action :set_paper_trail_whodunnit

    private

    def resource
      contract
    end

    def updated?
      ContractsService::Proposals::TotalInexecution.call(contract: contract)
    end
  end
end
