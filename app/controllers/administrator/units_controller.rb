module Administrator
  class UnitsController < AdminController
    load_and_authorize_resource

    expose :units, -> { find_units }

    def index
      render json: units, each_serializer: UnitSerializer
    end

    private

    def find_units
      Unit.accessible_by(current_ability).sorted
    end
  end
end
