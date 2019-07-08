module Search
  class CitiesController < Search::BaseController
    skip_before_action :auth!

    private

    def base_resources
      City.includes(:state)
    end
  end
end
