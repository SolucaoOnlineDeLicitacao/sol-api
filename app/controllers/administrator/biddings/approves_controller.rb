module Administrator
  class Biddings::ApprovesController < AdminController
    load_and_authorize_resource :bidding, parent: false

    expose :bidding

    before_action :set_paper_trail_whodunnit

    def update
      if approved?
        render status: :ok
      else
        render status: :unprocessable_entity
      end
    end

    private

    def approved?
      BiddingsService::Approve.call(bidding: bidding)
    end
  end
end
