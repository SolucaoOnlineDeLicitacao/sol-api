module Supp
  class Biddings::Lots::LotProposalsController < SuppController
    include CrudController

    load_and_authorize_resource except: [:create, :update]

    PERMITTED_PARAMS = [
      :id, :lot_id, :delivery_price, lot_group_item_lot_proposals_attributes: [
        :id, :lot_group_item_id, :price, :_destroy
      ]
    ].freeze

    expose :bidding
    expose :lot
    expose :lot_proposals, -> { find_lot_proposals }
    expose :lot_proposal

    before_action :set_paper_trail_whodunnit

    def index
      render json: paginated_resources, each_serializer: Supp::LotProposalSerializer
    end

    def show
      render json: resource, serializer: Supp::LotProposalSerializer
    end

    private

    def created?
      assign_parents
      authorize! :create, lot_proposal

      ProposalService::LotProposal::Create.call(lot_proposal: lot_proposal)
    end

    def updated?
      assign_parents
      authorize! :update, lot_proposal

      ProposalService::LotProposal::Update.call(lot_proposal: lot_proposal, params: lot_proposal_params)
    end

    def destroyed?
      ProposalService::LotProposal::Destroy.call(lot_proposal: lot_proposal)
    end

    def assign_parents
      lot_proposal.proposal = find_or_build_proposal
      lot_proposal.supplier = current_user
    end

    def find_or_build_proposal
      return current_proposal if current_proposal.present?

      build_proposal
    end

    def current_proposal
      @current_proposal ||= bidding.proposals.find_by(provider: current_provider)
    end

    def build_proposal
      Proposal.new(bidding: bidding, provider: current_provider, status: :draft)
    end

    def failure_errors
      resource.errors_as_json
        .merge({ lot_group_item_lot_proposals_errors: resource.lot_group_item_lot_proposals.map(&:errors_as_json) })
    end

    def find_lot_proposals
      LotProposal.accessible_by(current_ability).active_and_orderly_with(lot, [:draft])
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
