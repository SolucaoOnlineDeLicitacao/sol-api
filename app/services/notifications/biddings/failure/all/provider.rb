module Notifications
  class Biddings::Failure::All::Provider < Biddings::Base

    private

    def body_args
      bidding.title
    end

    def receivables
      suppliers
    end
  end
end
