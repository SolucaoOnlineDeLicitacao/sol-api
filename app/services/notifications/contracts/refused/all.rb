module Notifications
  class Contracts::Refused::All < Contracts::Base

    private

    def body_args
      [bidding.title]
    end

    def receivables
      [admin, user, supplier]
    end
  end
end
