module Notifications
  class Biddings::Draw::Admin < Biddings::Base

    private

    def body_args
      [bidding.title, I18n.l(bidding.draw_at)]
    end

    def receivables
      admin
    end

  end
end
