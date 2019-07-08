module Coop
  class LotProposals::RefusesController < CoopController
    load_and_authorize_resource :lot_proposal, parent: false

    expose :lot_proposal

    before_action :set_paper_trail_whodunnit

    delegate :event, to: :coop_refused_service

    def update
      if coop_refused?
        render status: :ok
      else
        render status: :unprocessable_entity, json: { errors: event&.errors_as_json }
      end
    end

    private

    def coop_refused?
      coop_refused_service.call
    end

    def coop_refused_service
      @coop_refused_service ||= ProposalService::Coop::LotProposal::Refuse.new(
        lot_proposal: lot_proposal,
        creator: current_user,
        comment: params[:comment]
      )
    end
  end
end
