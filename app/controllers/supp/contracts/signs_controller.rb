module Supp
  class Contracts::SignsController < SuppController
    include CrudController

    load_and_authorize_resource :contract, parent: false

    expose :contract

    before_action :set_paper_trail_whodunnit

    private

    def resource
      contract
    end

    def updated?
      ContractsService::Sign.call(
        contract: contract,
        type: 'supplier',
        user: current_user
      )
    end
  end
end
