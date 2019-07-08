module Notifications
  class Biddings::Failure::All::Admin < Biddings::Base

    private

    def body_args
      [bidding.title, comment_failure]
    end

    def receivables
      admin
    end

    def comment_failure
      current_failure_event&.comment
    end

    def current_failure_event
      bidding.event_bidding_failures&.last
    end
  end
end
