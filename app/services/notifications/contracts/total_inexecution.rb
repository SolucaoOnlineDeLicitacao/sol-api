module Notifications
  class Contracts::TotalInexecution < Contracts::Base

    private

    def body_args
      [contract.title, bidding.title]
    end

    def receivables
      [admin, user, supplier]
    end
  end
end
