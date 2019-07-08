module ImportsController
  extend ActiveSupport::Concern

  include CrudController

  PERMITTED_PARAMS = %i[file].freeze

  included do
    include Resource
    extend Resource

    expose :bidding
    expose :lot if resource_has_lot_proposal_import?
    expose resource_sym

    define_method("#{resource_name}_params") do
      params.require(resource_sym).permit(*PERMITTED_PARAMS)
    end
  end

  module Resource
    def resource
      send(resource_sym)
    end

    def resource_sym
      @resource_sym ||= resource_name.to_sym
    end

    def resource_has_lot_proposal_import?
      resource_name == 'lot_proposal_import'
    end

    def serializer
      "Supp::#{resource_name.camelize}Serializer".constantize
    end

    private

    def resource_name
      @resource_name ||= controller_name.singularize
    end
  end

  def show
    render json: resource, serializer: serializer
  end

  private

  def created?
    assign_parents
    authorize! :create, resource

    service_async_call
  end

  def assign_parents
    resource.bidding = bidding
    resource.provider = current_provider
  end
end
