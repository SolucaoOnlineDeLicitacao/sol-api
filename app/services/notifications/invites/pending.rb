module Notifications
  class Invites::Pending < Invites::Base

    private

    def body_args
      [provider.name, bidding.title]
    end

    def receivables
      users
    end
  end
end
