module Supp
  class Biddings::LotsController < SuppController
    include CrudController

    load_and_authorize_resource

    expose :bidding
    expose :lots, -> { find_lots }
    expose :lot

    def index
      render json: paginated_resources, each_serializer: Supp::LotSerializer
    end

    def show
      render json: lot, serializer: Supp::LotSerializer
    end

    private

    def resource
      lot
    end

    def resources
      lots
    end

    def find_lots
      bidding.lots.accessible_by(current_ability)
    end
  end
end
