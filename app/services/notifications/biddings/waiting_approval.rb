module Notifications
  class Biddings::WaitingApproval < Biddings::Base

    private

    def body_args
      bidding.title
    end

    def receivables
      admin
    end

  end
end
