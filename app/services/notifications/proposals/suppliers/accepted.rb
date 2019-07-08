module Notifications
  class Proposals::Suppliers::Accepted < Proposals::Base

    private

    def body_args
      [lots_name]
    end

    def receivables
      suppliers
    end

    def lots_name
      @lots_name ||= proposal.lots_name
    end

    def suppliers
      @suppliers ||= provider.suppliers
    end

    def provider
      @provider ||= proposal.provider
    end

    def bidding
      @bidding ||= proposal.bidding
    end

  end
end
