module Notifications
  class Biddings::Failure::Provider < Biddings::Base

    private

    def body_args
      bidding.title
    end

    def receivables
      suppliers
    end
  end
end
