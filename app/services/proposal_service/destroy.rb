module ProposalService
  class Destroy < Base
    include Call::Methods
    include TransactionMethods

    def main_method
      destroy_proposal!
    end

    private

    def destroy_proposal!
      execute_or_rollback do
        return abandoned_and_update_blockchain! if proposal.bidding.closed_invite?

        proposal.destroy!
        raise BlockchainError unless blockchain_delete.success?
      end
    end
  end
end
