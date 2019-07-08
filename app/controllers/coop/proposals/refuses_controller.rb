module Coop
  class Proposals::RefusesController < CoopController
    load_and_authorize_resource :proposal, parent: false

    expose :proposal

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
      @coop_refused_service ||= ProposalService::Coop::Refuse.new(
        proposal: proposal,
        creator: current_user,
        comment: params[:comment]
      )
    end
  end
end
