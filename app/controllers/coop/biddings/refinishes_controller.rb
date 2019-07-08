module Coop
  class Biddings::RefinishesController < CoopController
    load_and_authorize_resource :bidding, parent: false

    expose :bidding

    before_action :set_paper_trail_whodunnit

    def update
      if refinnish?
        render status: :ok
      else
        render status: :unprocessable_entity
      end
    end

    private

    def refinnish?
      BiddingsService::Refinish.call(bidding: bidding, user: current_user)
    end
  end
end
