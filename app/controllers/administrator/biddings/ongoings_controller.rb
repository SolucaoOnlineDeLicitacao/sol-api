module Administrator
  class Biddings::OngoingsController < AdminController
    include CrudController

    load_and_authorize_resource :bidding, parent: false

    expose :bidding

    before_action :set_paper_trail_whodunnit

    private

    def updated?
      current_user.general? && BiddingsService::Ongoing.call(bidding: bidding)
    end

    def resource
      bidding
    end
  end
end
