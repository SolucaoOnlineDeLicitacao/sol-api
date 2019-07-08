module Notifications
  class Contracts::Refused::User < Contracts::Base

    private

    def body_args
      [bidding.title, provider.name]
    end

    def receivables
      [admin, supplier]
    end
  end
end
