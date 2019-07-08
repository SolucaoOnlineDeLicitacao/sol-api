module Notifications
  class Biddings::CancellationRequests::Approved

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
      Notifications::Biddings::CancellationRequests::Approved::Provider.call(@bidding)
      Notifications::Biddings::CancellationRequests::Approved::Cooperative.call(@bidding)
    end

  end
end
