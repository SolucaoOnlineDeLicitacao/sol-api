require './lib/dashboards/cooperative'

module Coop
  class DashboardsController < CoopController
    expose :biddings, -> { find_biddings }

    def show
      render json: cooperative_dashboard_json
    end

    private

    def cooperative_dashboard_json
      ::Dashboards::Cooperative.new(biddings: biddings).to_json
    end

    def find_biddings
      current_cooperative.biddings.active.sorted
    end
  end
end
