module Notifications
  class Proposals::CoopRefused < Proposals::Base

    private

    def extra_args
      { covenant_id: bidding.covenant_id, bidding_id: bidding.id }
    end

    def receivables
      admin
    end
  end
end
