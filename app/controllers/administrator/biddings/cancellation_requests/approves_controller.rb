module Administrator
  class Biddings::CancellationRequests::ApprovesController < AdminController
    load_and_authorize_resource :bidding, parent: false

    expose :bidding

    before_action :set_paper_trail_whodunnit

    delegate :event, to: :approve_service

    def update
      if approved?
        render status: :ok, json: bidding
      else
        render status: :unprocessable_entity, json: { errors: event&.errors_as_json }
      end
    end

    private

    def approved?
      approve_service.call
    end

    def approve_service
      @approve_service ||=
        BiddingsService::CancellationRequests::Approve.new(service_params)
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
