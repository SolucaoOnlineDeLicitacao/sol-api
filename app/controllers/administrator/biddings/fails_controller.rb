module Administrator
  class Biddings::FailsController < AdminController
    load_and_authorize_resource :bidding, parent: false

    expose :bidding

    before_action :set_paper_trail_whodunnit

    delegate :event, to: :admin_failure_service

    def update
      if admin_failure?
        render status: :ok
      else
        render status: :unprocessable_entity, json: { errors: event&.errors_as_json }
      end
    end

    private

    def admin_failure?
      admin_failure_service.call
    end

    def admin_failure_service
      @admin_failure_service ||= BiddingsService::AdminFailure.new(
        bidding: bidding,
        creator: current_user,
        comment: params[:comment]
      )
    end
  end
end
