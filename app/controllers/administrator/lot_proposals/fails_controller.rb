module Administrator
  class LotProposals::FailsController < AdminController
    load_and_authorize_resource :lot_proposal, parent: false

    expose :lot_proposal

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
      @fail_service ||= LotsService::Fail.new(
        lot_proposal: lot_proposal,
        creator: current_user,
        comment: params[:comment]
      )
    end
  end
end
