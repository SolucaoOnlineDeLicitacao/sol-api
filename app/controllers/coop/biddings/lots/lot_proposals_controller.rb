module Coop
  class Biddings::Lots::LotProposalsController < CoopController
    include CrudController

    load_and_authorize_resource :lot_proposal, parent: false

    PERMITTED_PARAMS = [
      :id, :name, lot_proposal_group_items_attributes: [
        :id, :group_item_id, :quantity, :_destroy
      ]
    ].freeze

    expose :bidding
    expose :lot
    expose :lot_proposals, -> { find_lot_proposals }
    expose :lot_proposal

    def index
      render json: paginated_resources, each_serializer: Coop::LotProposalSerializer
    end

    def show
      render json: resource, serializer: Coop::LotProposalSerializer
    end

    private

    def find_lot_proposals
      LotProposal.accessible_by(current_ability).active_and_orderly_with(lot, [:draft, :abandoned])
    end

    def resource
      lot_proposal
    end

    def resources
      lot_proposals
    end

    def lot_proposal_params
      params.require(:lot_proposal).permit(*PERMITTED_PARAMS)
    end
  end
end
