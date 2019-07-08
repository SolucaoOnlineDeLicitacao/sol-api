module Policies
  module Proposal
    class ReadPolicy
      attr_accessor :proposal, :supplier

      def initialize(proposal, supplier)
        @proposal = proposal
        @supplier = supplier
      end

      def self.allowed?(proposal, supplier)
        new(proposal, supplier).allowed?
      end

      def allowed?
        ::Proposal.read_policy_by(supplier.id).where(id: proposal.id).any?
      end
    end
  end
end
