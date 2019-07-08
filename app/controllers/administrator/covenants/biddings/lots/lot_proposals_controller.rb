module Administrator
  class Covenants::Biddings::Lots::LotProposalsController < AdminController
    include CrudController

    load_and_authorize_resource :lot_proposal, parent: false

    expose :lot
    expose :lot_proposals, -> { find_lot_proposals }
    expose :lot_proposal

    def index
      render json: paginated_resources, each_serializer: Administrator::LotProposalSerializer
    end

    private

    def resource
      lot_proposal
    end

    def resources
      lot_proposals
    end

    def find_lot_proposals
      LotProposal.accessible_by(current_ability).active_and_orderly_with(lot, [:draft, :abandoned])
    end
  end
end
