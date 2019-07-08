module Policies
  module Bidding
    class InvitePolicy
      attr_accessor :bidding, :invites, :provider

      def initialize(bidding, provider)
        @bidding = bidding
        @invites = bidding.invites
        @provider = provider
      end

      def allowed?
        @bidding.unrestricted? || provider_invited?
      end

      def pending?
        ! allowed? && provider_pending?
      end

      private

      def provider_invited?
        @invites.approved.where(provider: provider).any?
      end

      def provider_pending?
        @invites.pending.where(provider: provider).any?
      end

    end
  end
end
