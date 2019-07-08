module Administrator
  class CovenantsController < AdminController
    include CrudController

    load_and_authorize_resource

    PERMITTED_PARAMS = [
      :name, :number, :status, :city_id, :signature_date, :validity_date,
      :cooperative_id, :admin_id, :estimated_cost
    ].freeze

    expose :covenants, -> { find_covenants }
    expose :covenant

    before_action :set_paper_trail_whodunnit

    private

    def resource
      covenant
    end

    def resources
      covenants
    end

    def find_covenants
      Covenant.accessible_by(current_ability)
    end

    def covenant_params
      params.require(:covenant).permit(*PERMITTED_PARAMS)
    end
  end
end
