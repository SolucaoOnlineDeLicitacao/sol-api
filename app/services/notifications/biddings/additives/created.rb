module Notifications
  class Biddings::Additives::Created < Biddings::Base

    private

    def body_args
      [bidding.title, I18n.l(bidding.closing_date)]
    end

    def receivables
      # we can send the same message to all by grouping the receivables
      [admin, suppliers_from_proposals_and_invites, users]
    end

  end
end
