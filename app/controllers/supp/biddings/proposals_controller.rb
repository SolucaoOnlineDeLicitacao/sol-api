module Supp
  class Biddings::ProposalsController < SuppController
    include CrudController

    load_and_authorize_resource :bidding
    load_and_authorize_resource through: :bidding, except: :create

    PERMITTED_PARAMS = [
      :id, :name, lot_proposals_attributes: [
        :id, :lot_id, :delivery_price, lot_group_item_lot_proposals_attributes: [
          :id, :lot_group_item_id, :price, :_destroy
        ]
      ]
    ].freeze

    expose :bidding
    expose :proposals, -> { find_proposals }
    expose :proposal

    before_action :set_paper_trail_whodunnit

    def index
      render json: paginated_resources,
             each_serializer: Supp::ProposalSerializer
    end

    def show
      render json: resource,
             serializer: Supp::ProposalSerializer,
             include: ['lot_proposals.lot_group_item_lot_proposals']
    end

    def finish
      render status: finished_render_status
    end

    private

    def finished_render_status
      finished? ? :ok : :unprocessable_entity
    end

    def finished?
      ProposalService::Sent.call(proposal)
    end

    def assign_parents
      proposal.provider = current_provider
      proposal.bidding = bidding
    end

    def created?
      # load_and_authorize_resource through doesnt work with multiple
      # parent params (we need bidding and provider)
      assign_parents
      authorize! :create, proposal

      ProposalService::Create.call(proposal: proposal,
                                   user: current_user,
                                   provider: current_provider,
                                   bidding: bidding)
    end

    def updated?
      assign_parents
      authorize! :update, proposal

      ProposalService::Update.call(proposal: proposal, params: proposal_params)
    end

    def destroyed?
      ProposalService::Destroy.call(proposal: proposal)
    end

    def failure_errors
      resource.errors_as_json
        .merge(lot_proposals_errors: resource.lot_proposals.map(&:lot_group_item_lot_proposals).map{ |i| i.map(&:errors_as_json) })
        .merge(lot_proposals_error: resource.lot_proposals.map(&:errors_as_json))
    end

    def resource
      proposal
    end

    def resources
      proposals
    end

    def proposal_params
      params.require(:proposal).permit(*PERMITTED_PARAMS)
    end

    # we wont list draft proposals
    def find_proposals
      bidding.proposals.accessible_by(current_ability).where.not(status: :draft)
    end
  end
end
