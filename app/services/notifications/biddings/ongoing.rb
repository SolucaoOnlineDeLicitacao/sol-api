module Notifications
  class Biddings::Ongoing

    attr_accessor :bidding

    def initialize(bidding)
      @bidding = bidding
    end

    def self.call(bidding)
      new(bidding).call
    end

    def call
      notify
    end

    private

    def notify
      Notifications::Biddings::Ongoing::InvitedProvider.call(bidding)
      Notifications::Biddings::Ongoing::Cooperative.call(bidding)
      Notifications::Biddings::Ongoing::ClassificationProvider.call(bidding) unless bidding.closed_invite?
    end

  end
end
