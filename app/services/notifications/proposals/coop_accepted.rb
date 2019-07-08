module Notifications
  class Proposals::CoopAccepted < Proposals::Base

    private

    def extra_args
      { covenant_id: bidding.covenant_id, bidding_id: bidding.id }
    end

    def receivables
      admin
    end
  end
end
