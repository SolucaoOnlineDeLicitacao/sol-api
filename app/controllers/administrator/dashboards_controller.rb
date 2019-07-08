require './lib/dashboards/admin'

module Administrator
  class DashboardsController < AdminController
    PERMITTED_PARAMS = [:east, :north, :south, :west].freeze

    def show
      render json: admin_dashboard_json
    end

    private

    def admin_dashboard_json
      ::Dashboards::Admin.new(admin: current_user, bounds_params: bounds_params).to_json
    end

    def bounds_params
      params.require(:bounds).permit(*PERMITTED_PARAMS)
    end
  end
end
