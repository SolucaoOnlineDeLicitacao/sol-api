module Coop::Contract
  class Refused::CloneBiddingsController < CoopController
    include CrudController

    load_and_authorize_resource :contract, parent: false

    before_action :updates_deleted_at
    before_action :set_paper_trail_whodunnit

    expose :contract

    private

    def resource
      contract
    end

    def updated?
      ContractsService::Clone::Refused.call(contract: contract)
    end

    def updates_deleted_at
      contract.deleted_at = DateTime.current
    end
  end

end
