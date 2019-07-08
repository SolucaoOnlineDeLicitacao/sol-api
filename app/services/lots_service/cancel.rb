module LotsService
  class Cancel
    include TransactionMethods
    include Call::WithExceptionsMethods

    def main_method
      cancel
    end

    def call_exception
      ActiveRecord::RecordInvalid
    end

    private

    def cancel
      execute_or_rollback do
        cancel_lot_proposals!
        recalculate_quantity!
        update_proposal_blockchain!
      end
    end

    def bidding
      @bidding ||= proposal.bidding
    end

    def cancel_lot_proposals!
      lot_proposals.find_each { |lot_proposal| lot_proposal.lot.canceled! }
    end

    def lot_proposals
      @lot_proposals ||= proposal.lot_proposals
    end

    def recalculate_quantity!
      RecalculateQuantityService.call!(covenant: bidding.covenant)
    end

    def update_proposal_blockchain!
      response = Blockchain::Proposal::Update.call(proposal)
      raise BlockchainError unless response.success?
    end
  end
end
