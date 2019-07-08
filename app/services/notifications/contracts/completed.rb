module Notifications
  class Contracts::Completed < Contracts::Base

    private

    def body_args
      [contract.title, bidding.title]
    end

    def receivables
      [admin, user, supplier]
    end
  end
end
