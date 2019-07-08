module Notifications
  class Proposals::Lots::Base < Proposals::Base

    attr_accessor :lot, :bidding

    def initialize(proposal, lot)
      super(proposal)
      @lot = lot
    end

    def self.call(proposal, lot)
      new(proposal, lot).call
    end

    private

    def body_args
      [lot.name, bidding.title]
    end

    def extra_args
      base_extra_args
    end

    def base_extra_args
      { lot_id: lot.id, bidding_id: bidding.id }
    end
  end
end
