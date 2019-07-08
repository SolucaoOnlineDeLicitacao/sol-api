module Notifications
  class Biddings::CancellationRequests::Approved::Provider < Biddings::Base
    include CurrentEventCancellable

    private

    def body_args
      [bidding.title, comment_response]
    end

    def receivables
      suppliers
    end

    def event_resource
      bidding
    end
  end
end
