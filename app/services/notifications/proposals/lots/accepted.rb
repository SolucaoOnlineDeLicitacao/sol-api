module Notifications
  class Proposals::Lots::Accepted < Proposals::Lots::Base

    private

    def body_args
      [provider.name, lot.name, bidding.title]
    end

    def receivables
      users
    end
  end
end
