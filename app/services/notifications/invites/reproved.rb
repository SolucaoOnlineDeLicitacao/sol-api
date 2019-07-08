module Notifications
  class Invites::Reproved < Invites::Base

    private

    def body_args
      [bidding.title, cooperative.name]
    end

    def receivables
      suppliers
    end
  end
end
