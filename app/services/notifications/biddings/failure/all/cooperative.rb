module Notifications
  class Biddings::Failure::All::Cooperative < Biddings::Base

    private

    def body_args
      bidding.title
    end

    def receivables
      users
    end
  end
end
