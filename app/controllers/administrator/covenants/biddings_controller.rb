module Administrator
  class Covenants::BiddingsController < AdminController
    include CrudController

    load_and_authorize_resource :bidding, parent: false

    PERMITTED_PARAMS = [
      :id, :name, bidding_items_attributes: [
        :id, :item_id, :quantity, :estimated_cost, :_destroy
      ]
    ].freeze

    expose :covenant
    expose :bidding
    expose :biddings, -> { find_biddings }

    def index
      render json: paginated_resources, each_serializer: Coop::BiddingSerializer
    end

    def show
      render json: resource, serializer: Coop::BiddingSerializer
    end

    private

    def resource
      bidding
    end

    def resources
      biddings
    end

    def find_biddings
      covenant.biddings.accessible_by(current_ability).not_draft
    end

    def bidding_params
      params.require(:bidding).permit(*PERMITTED_PARAMS)
    end
  end
end
