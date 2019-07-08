module Policies
  module LotProposal
    class ReadPolicy
      attr_accessor :lot_proposal, :supplier

      def initialize(lot_proposal, supplier)
        @lot_proposal = lot_proposal
        @supplier = supplier
      end

      def self.allowed?(lot_proposal, supplier)
        new(lot_proposal, supplier).allowed?
      end

      def allowed?
        ::LotProposal.read_policy_by(supplier.id).where(id: lot_proposal.id).any?
      end
    end
  end
end
