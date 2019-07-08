module Notifications
  class Biddings::Draw::SentProvider < Biddings::Base

    private

    def body_args
      [bidding.title, I18n.l(bidding.draw_at)]
    end

    def receivables
      suppliers
    end

    def proposals
      # override default proposals to get only sent proposals
      @proposals ||= @bidding.proposals.sent
    end
  end
end
