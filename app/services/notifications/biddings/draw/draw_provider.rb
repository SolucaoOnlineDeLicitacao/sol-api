module Notifications
  class Biddings::Draw::DrawProvider < Biddings::Base

    private

    def body_args
      [bidding.title, I18n.l(bidding.draw_at)]
    end

    def receivables
      suppliers
    end

    def proposals
      # override default proposals to get only draw proposals
      @proposals ||= @bidding.proposals.draw
    end
  end
end
