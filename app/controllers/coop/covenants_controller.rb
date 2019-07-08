module Coop
  class CovenantsController < CoopController
    include CrudController

    load_and_authorize_resource

    expose :covenants, -> { find_covenants }
    expose :covenant

    private

    def resource
      covenant
    end

    def resources
      covenants
    end

    def find_covenants
      current_cooperative.covenants.accessible_by(current_ability)
    end
  end
end
