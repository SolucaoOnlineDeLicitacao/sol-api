require './lib/dashboards/supplier'

module Supp
  class DashboardsController < SuppController
    expose :biddings, -> { find_biddings }

    def show
      render json: supplier_dashboard_json
    end

    private

    def supplier_dashboard_json
      ::Dashboards::Supplier.new(biddings: biddings).to_json
    end

    def find_biddings
      Bidding.active.sorted
    end
  end
end
