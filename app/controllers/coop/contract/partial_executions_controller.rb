module Coop
  class Contract::PartialExecutionsController < CoopController
    include CrudController

    load_and_authorize_resource :contract, parent: false

    PERMITTED_PARAMS = [
      :id, returned_lot_group_items_attributes: [
        :id, :lot_group_item_id, :quantity
      ]
    ].freeze

    expose :contract

    before_action :set_paper_trail_whodunnit

    private

    def resource
      contract
    end

    def updated?
      ContractsService::PartialExecution.call(contract: contract, contract_params: contract_params)
    end

    def failure_errors
      resource.errors_as_json
        .merge(returned_lot_group_items_errors: resource.returned_lot_group_items.map(&:errors_as_json))
    end

    def contract_params
      params.require(:contract).permit(*PERMITTED_PARAMS)
    end
  end
end
