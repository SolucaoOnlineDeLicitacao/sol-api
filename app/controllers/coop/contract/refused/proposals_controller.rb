module Coop::Contract
  class Refused::ProposalsController < CoopController
    include CrudController

    load_and_authorize_resource :contract, parent: false

    before_action :set_paper_trail_whodunnit

    expose :contract

    private

    def resource
      contract
    end

    def updated?
      ContractsService::Proposals::Refused.call(contract: contract)
    end
  end
end
