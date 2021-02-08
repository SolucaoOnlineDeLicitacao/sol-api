module Administrator
  class BiddingsController < AdminController
    include CrudController

    load_and_authorize_resource

    expose :bidding
    expose :biddings, -> { find_biddings }

    def index
      render json: paginated_resources, each_serializer: Coop::BiddingSerializer
    end

    def show
      render json: bidding, serializer: Coop::BiddingSerializer
    end

    private

    def resources
      biddings
    end

    def find_biddings
      Bidding.accessible_by(current_ability)
    end
  end
end
