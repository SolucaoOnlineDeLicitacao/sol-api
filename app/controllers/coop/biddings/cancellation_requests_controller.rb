module Coop
  class Biddings::CancellationRequestsController < CoopController
    load_and_authorize_resource :bidding

    expose :bidding

    before_action :set_paper_trail_whodunnit

    delegate :event, to: :cancellation_request_service

    def create
      if cancellation_request?
        render status: :ok, json: bidding
      else
        render status: :unprocessable_entity, json: { errors: event&.errors_as_json }
      end
    end

    private

    def cancellation_request?
      cancellation_request_service.call
    end

    def cancellation_request_service
      @cancellation_request_service ||=
        BiddingsService::CancellationRequest.new(service_params)
    end

    def service_params
      {
        bidding: bidding,
        comment: params[:comment],
        creator: current_user
      }
    end
  end
end
