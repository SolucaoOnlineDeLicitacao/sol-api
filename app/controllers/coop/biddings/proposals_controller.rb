module Coop
  class Biddings::ProposalsController < CoopController
    include CrudController

    load_and_authorize_resource :proposal, parent: false

    expose :bidding
    expose :proposals, -> { find_proposals }
    expose :proposal

    def index
      render json: paginated_resources, each_serializer: Coop::ProposalSerializer
    end

    def show
      render json: resource, serializer: Coop::ProposalSerializer, include: ['lot_proposals.lot_group_item_lot_proposals']
    end

    private

    def resource
      proposal
    end

    def resources
      proposals
    end

    def find_proposals
      bidding.proposals.accessible_by(current_ability).active_and_orderly
    end
  end
end
