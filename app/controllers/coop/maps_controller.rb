require './lib/maps'

module Coop
  class MapsController < CoopController
    
    def show
      render json: cooperative_dashboard_map
    end

    private

    def cooperative_dashboard_map
      Maps.new(resource: current_cooperative, collection_klass: ::Provider).to_json
    end

  end
end
