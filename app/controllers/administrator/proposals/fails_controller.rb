module Administrator
  class Proposals::FailsController < AdminController
    load_and_authorize_resource :proposal, parent: false

    expose :proposal

    before_action :set_paper_trail_whodunnit

    delegate :event, to: :fail_service

    def update
      if failed?
        render status: :ok
      else
        render status: :unprocessable_entity, json: { errors: event&.errors_as_json }
      end
    end

    private

    def failed?
      fail_service.call
    end

    def fail_service
      @fail_service ||= ProposalService::Fail.new(
        proposal: proposal,
        creator: current_user,
        comment: params[:comment]
      )
    end
  end
end
