module Administrator
  class ProvidersController < AdminController
    include CrudController

    load_and_authorize_resource

    PERMITTED_PARAMS = [
      :name, :document, :type,

      address_attributes: [
        :id, :address, :number, :neighborhood, :city_id, :cep, :complement,
        :reference_point, :latitude, :longitude
      ],

      legal_representative_attributes: [
        :id, :name, :nationality, :civil_state, :rg, :cpf, :valid_until,

        address_attributes: [
          :id, :address, :number, :neighborhood, :city_id, :cep, :complement,
          :reference_point, :latitude, :longitude
        ]
      ],
      provider_classifications_attributes: [
        :id, :classification_id, :_destroy
      ]
    ].freeze

    expose :providers, -> { find_providers }
    expose :provider

    before_action :set_paper_trail_whodunnit

    def index
      paginate json: paginated_resources, each_serializer: Administrator::ProviderSerializer
    end

    def show
      render json: resource, serializer: Administrator::ProviderSerializer
    end

    def block
      if blocked?
        render status: :ok, json: resource
      else
        render status: :unprocessable_entity, json: { errors: block_service.event&.errors_as_json }
      end
    end

    def unblock
      if unblocked?
        render status: :ok, json: resource
      else
        render status: :unprocessable_entity, json: { errors: unblock_service.event&.errors_as_json }
      end
    end

    private

    def resource
      provider
    end

    def resources
      providers
    end

    def find_providers
      Provider.accessible_by(current_ability).includes(:address)
    end

    def individual_params
      provider_params
    end

    def company_params
      provider_params
    end

    def provider_params
      params.require(:provider).permit(*PERMITTED_PARAMS)
    end

    def blocked?
      block_service.call
    end

    def unblocked?
      unblock_service.call
    end

    def block_service
      @block_service ||= ProvidersService::Block.new(event_params)
    end

    def unblock_service
      @unblock_service ||= ProvidersService::Unblock.new(event_params)
    end

    def event_params
      { creator: current_user, provider: resource, comment: params[:comment] }
    end
  end
end
