module Notifications
  class Proposals::Lots::CoopAccepted < Proposals::Lots::Base

    private

    def extra_args
      base_extra_args.merge!({ covenant_id: bidding.covenant_id })
    end

    def receivables
      admin
    end
  end
end
