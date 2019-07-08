module Notifications
  class Biddings::Approved < Biddings::Base

    private

    def body_args
      [bidding.title, I18n.l(bidding.start_date)]
    end

    def receivables
      users
    end

  end
end
