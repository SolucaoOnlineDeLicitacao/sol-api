module Policies
  module Proposal
    class UploadPolicy
      attr_accessor :proposal_import

      delegate :bidding, :provider, to: :proposal_import

      def initialize(proposal_import)
        @proposal_import = proposal_import
      end

      def self.allowed?(proposal_import)
        new(proposal_import).allowed?
      end

      def allowed?
        bidding.ongoing? && invite_allowed?
      end

      private

      def invite_allowed?
        Policies::Bidding::InvitePolicy.new(bidding, provider).allowed?
      end
    end
  end
end
