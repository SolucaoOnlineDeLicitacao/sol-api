module Supp
  class BiddingsController < SuppController
    include CrudController

    load_and_authorize_resource

    expose :biddings, -> { find_biddings }
    expose :bidding

    def index
      paginate json: paginated_resources, each_serializer: Coop::BiddingSerializer
    end

    def show
      render json: bidding, serializer: Coop::BiddingSerializer
    end

    private

    def resource
      bidding
    end

    def resources
      biddings
    end

    def find_biddings
      Bidding.by_provider(current_provider).accessible_by(current_ability)
    end
  end
end
