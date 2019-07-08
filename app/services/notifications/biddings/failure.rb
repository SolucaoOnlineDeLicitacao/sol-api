module Notifications
  class Biddings::Failure

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
      Notifications::Biddings::Failure::Provider.call(bidding)
      Notifications::Biddings::Failure::Cooperative.call(bidding)
    end

  end
end
