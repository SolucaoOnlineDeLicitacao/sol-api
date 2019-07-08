module Coop
  class ProvidersController < CoopController
    include CrudController

    load_and_authorize_resource

    expose :providers, -> { find_providers }
    expose :provider

    def index
      paginate json: paginated_resources, each_serializer: Coop::ProviderSerializer
    end

    def show
      render json: resource, serializer: Coop::ProviderSerializer
    end

    private

    def resources
      providers
    end

    def resource
      provider
    end

    def find_providers
      if classification_ids.present?
        return base_providers.by_classification_ids(classification_ids)
      end

      base_providers
    end

    def base_providers
      Provider.with_access.joins(:suppliers).accessible_by(current_ability).distinct(:id).sorted
    end

    def classification_ids
      @classification_ids ||= params["classification_ids"]
    end
  end
end
