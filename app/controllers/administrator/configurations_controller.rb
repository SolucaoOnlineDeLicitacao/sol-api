module Administrator
  class ConfigurationsController < AdminController
    include CrudController

    PERMITTED_PARAMS = [
      :id, :endpoint_url, :token, :schedule
    ].freeze

    expose :configurations, -> { Integration::Configuration.order(:type) }
    expose :configuration, model: Integration::Configuration

    def import
      "Import::#{resource.type.split('::')[1]}Worker".constantize.perform_async
      resource.status_queued!

      render json: { status: resource.status }
    end

    private

    def resource
      configuration
    end

    def resources
      configurations
    end

    def configuration_params
      params.require(:configuration).permit(*PERMITTED_PARAMS)
    end

    # override CrudController
    def paginated_resources
      resources
    end

    def resource_key
      'configuration'
    end
  end
end
