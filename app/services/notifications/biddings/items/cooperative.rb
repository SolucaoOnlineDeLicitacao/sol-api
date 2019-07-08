module Notifications
  class Biddings::Items::Cooperative < Biddings::Base
    attr_accessor :item

    def initialize(bidding, item)
      @bidding = bidding
      @item = item
    end

    def self.call(bidding, item)
      new(bidding, item).call
    end

    private

    def body_args
      [bidding.title, item.title]
    end

    def receivables
      users
    end
  end
end
