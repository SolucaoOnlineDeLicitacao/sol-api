module Policies
  module Proposal
    class SendPolicy
      attr_accessor :proposal

      delegate :bidding, :provider, to: :proposal

      def initialize(proposal)
        @proposal = proposal
      end

      def self.allowed?(proposal)
        new(proposal).allowed?
      end

      def allowed?
        bidding_allowed? && invite_allowed?
      end

      private

      def bidding_allowed?
        bidding.ongoing? || (bidding.draw? && proposal.draw?)
      end

      def invite_allowed?
        Policies::Bidding::InvitePolicy.new(bidding, provider).allowed?
      end
    end
  end
end
