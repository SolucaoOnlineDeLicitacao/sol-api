module Notifications
  class Proposals::Lots::Fail < Proposals::Lots::Base

    attr_accessor :event

    def initialize(proposal, lot, event)
      super(proposal, lot)
      @event = event
    end

    def self.call(proposal, lot, event)
      new(proposal, lot, event).call
    end

    private

    def body_args
      [provider.name, lot.name, bidding.title, event.comment]
    end

    def receivables
      users
    end
  end
end
