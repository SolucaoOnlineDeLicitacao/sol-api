module Notifications
  class Biddings::Draw::Cooperative < Biddings::Base

    private

    def body_args
      [bidding.title, I18n.l(bidding.draw_at)]
    end

    def receivables
      users
    end
  end
end
