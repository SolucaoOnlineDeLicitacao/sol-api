require './lib/maps'

module Supp
  class MapsController < SuppController

    def show
      render json: supplier_dashboard_map
    end

    private

    def supplier_dashboard_map
      Maps.new(resource: current_provider, collection_klass: ::Cooperative).to_json
    end
  end
end
