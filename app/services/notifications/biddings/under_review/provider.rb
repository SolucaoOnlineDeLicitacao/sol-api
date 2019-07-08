module Notifications
  class Biddings::UnderReview::Provider < Biddings::Base

    private

    def body_args
      [bidding.title, cooperative.name]
    end

    def receivables
      suppliers_from_proposals_and_invites
    end
  end
end
