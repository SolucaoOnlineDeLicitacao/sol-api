module Notifications
  class Biddings::Finished < Biddings::Base

    private

    def body_args
      bidding.title
    end

    def receivables
      # we can send the same message to all by grouping the receivables
      [admin, suppliers_from_proposals_and_invites, users]
    end

  end
end
