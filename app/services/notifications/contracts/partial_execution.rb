module Notifications
  class Contracts::PartialExecution < Contracts::Base

    private

    def body_args
      [contract.title, bidding.title]
    end

    def receivables
      [admin, user, supplier]
    end
  end
end
