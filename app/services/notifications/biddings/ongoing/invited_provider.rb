module Notifications
  class Biddings::Ongoing::InvitedProvider < Biddings::Base

    private

    def body_args
      bidding.title
    end

    def receivables
      suppliers
    end

    def providers
      # override providers to use approved_invites providers only
      @providers ||= Provider.joins(:invites).where(invites: approved_invites)
    end

    def approved_invites
      @approved_invites ||= @bidding.invites.approved
    end
  end
end
