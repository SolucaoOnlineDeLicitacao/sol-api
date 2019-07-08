module Notifications
  class Contracts::Refused::Supplier < Contracts::Base

    private

    def body_args
      [bidding.title, provider.name]
    end

    def receivables
      [admin, user]
    end
  end
end
