module Notifications
  class Biddings::UnderReview::Admin < Biddings::Base

    private

    def body_args
      [bidding.title, cooperative.name]
    end

    def receivables
      admin
    end

  end
end
