module Administrator
  class Biddings::ForceReviewsController < AdminController
    include CrudController

    load_and_authorize_resource :bidding, parent: false

    expose :bidding

    before_action :set_paper_trail_whodunnit

    private

    def updated?
      BiddingsService::Review.call(bidding: bidding)
    end

    def resource
      bidding
    end
  end
end
