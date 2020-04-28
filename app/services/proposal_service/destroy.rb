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
        return abandoned_and_update_blockchain! if abandon_proposal?

        proposal.destroy!
        # não criamos/atualizamos/deletamos propostas em rascunho
        return true if proposal.draft?

        raise BlockchainError unless blockchain_delete.success?
      end
    end

    def abandon_proposal?
      proposal.bidding.closed_invite? && proposal.sent?
    end

  end
end
