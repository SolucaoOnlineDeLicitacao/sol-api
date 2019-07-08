module Coop
  class Biddings::WaitingsController < CoopController
    load_and_authorize_resource :bidding, parent: false

    expose :bidding

    before_action :set_paper_trail_whodunnit

    def update
      if waiting?
        render status: :ok
      else
        render status: :unprocessable_entity, json: { errors: bidding.errors_as_json }
      end
    end

    private

    def waiting?
      BiddingsService::Waiting.call(bidding: bidding)
    end
  end
end
