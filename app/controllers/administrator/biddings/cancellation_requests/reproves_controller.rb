module Administrator
  class Biddings::CancellationRequests::ReprovesController < AdminController
    load_and_authorize_resource :bidding, parent: false

    expose :bidding

    before_action :set_paper_trail_whodunnit

    delegate :event, to: :reprove_service

    def update
      if reproved?
        render status: :ok, json: bidding
      else
        render status: :unprocessable_entity, json: { errors: event&.errors_as_json }
      end
    end

    private

    def reproved?
      reprove_service.call
    end

    def reprove_service
      @reprove_service ||=
        BiddingsService::CancellationRequests::Reprove.new(service_params)
    end

    def service_params
      {
        bidding: bidding,
        cancellation_request_id: params[:cancellation_request_id],
        comment: params[:comment]
      }
    end
  end
end
