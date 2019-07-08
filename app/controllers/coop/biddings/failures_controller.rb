module Coop
  class Biddings::FailuresController < CoopController
    load_and_authorize_resource :bidding, parent: false

    expose :bidding

    before_action :set_paper_trail_whodunnit

    delegate :event, to: :event_service
    delegate :event_service, to: :service

    def update
      if failure
        render status: :ok
      else
        render status: :unprocessable_entity, json: { errors: event&.errors_as_json }
      end
    end

    private

    def failure
      service.call
    end

    def service
      @service ||= BiddingsService::Failure.new(attributes)
    end

    def attributes
      {
        bidding: bidding,
        comment: params[:comment],
        creator: current_user
      }
    end
  end
end
