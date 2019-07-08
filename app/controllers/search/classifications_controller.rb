module Search
  class ClassificationsController < Search::BaseController

    LIMIT = 50.freeze

    def index
      render json: resources.to_json(whitelisted_params)
    end

    private

    def base_resources
      Classification.includes(:classification).references(:classification).order(:code)
    end

    def resources
      return base_resources unless filter_param
      base_resources.where(classification_id: filter_param)
    end

    def filter_param
      params.fetch(:classification_id, nil)
    end

    def whitelisted_params
      { only: [:id, :classification_id], methods: :text }
    end

    def auth!
      # skips_before_action
      true
    end

  end
end
