module Supp
  class ContractsController < SuppController
    include BaseContractsController

    load_and_authorize_resource

    private

    def find_contracts
      Contract.by_provider(current_provider.id).accessible_by(current_ability).not_refused
    end
  end
end
