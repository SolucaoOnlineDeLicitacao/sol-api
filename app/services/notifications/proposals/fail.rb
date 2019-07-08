module Notifications
  class Proposals::Fail < Proposals::Base

    attr_accessor :event

    def initialize(proposal, event)
      super(proposal)
      @event = event
    end

    def self.call(proposal, event)
      new(proposal, event).call
    end

    private

    def body_args
      [provider.name, bidding.title, event.comment]
    end

    def receivables
      users
    end
  end
end
