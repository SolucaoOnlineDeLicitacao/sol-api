module Administrator
  class Biddings::ReprovesController < AdminController
    load_and_authorize_resource :bidding, parent: false

    expose :bidding

    before_action :set_paper_trail_whodunnit

    def update
      if reprove_bidding
        render status: :ok
      else
        render status: :unprocessable_entity, json: { errors: event&.errors_as_json }
      end
    end

    private

    def reprove_bidding
      service.call
    end

    def service
      @service ||= BiddingsService::Reprove.new(service_params)
    end

    def event
      @event ||= service.event
    end

    def service_params
      {
        bidding: bidding,
        comment: params[:comment],
        user: current_user
      }
    end
  end
end
