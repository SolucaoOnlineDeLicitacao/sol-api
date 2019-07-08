module Coop
  class Biddings::FinishesController < CoopController
    load_and_authorize_resource :bidding, parent: false

    expose :bidding

    before_action :set_paper_trail_whodunnit

    def update
      if finnished?
        render status: :ok
      else
        render status: :unprocessable_entity
      end
    end

    private

    def finnished?
      BiddingsService::Finish.call(bidding: bidding, user: current_user)
    end
  end
end
