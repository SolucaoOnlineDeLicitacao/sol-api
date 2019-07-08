module Coop
  class ContractsController < CoopController
    include BaseContractsController

    load_and_authorize_resource :contract, class: 'Contract'

    private

    def find_contracts
      current_cooperative.contracts.accessible_by(current_ability)
    end
  end
end
