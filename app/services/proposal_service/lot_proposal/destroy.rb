module ProposalService::LotProposal
  class Destroy < ProposalService::Base
    include Call::Methods
    include TransactionMethods

    delegate :proposal, to: :lot_proposal

    def main_method
      proposal_change_status_or_destroy
    end

    private

    def proposal_change_status_or_destroy
      execute_or_rollback do
        lot_proposal.destroy!

        return abandoned_and_update_blockchain! if abandon_proposal?
        return draft_and_update_blockchain! if proposal_has_others_lots?

        proposal.destroy!
        # não criamos/atualizamos/deletamos propostas em rascunho
        return true if proposal.draft?

        raise BlockchainError unless blockchain_delete.success?
      end
    end

    def abandon_proposal?
      proposal.bidding.closed_invite? && proposal.sent?
    end

    def proposal_has_others_lots?
      proposal.lot_proposals.count >= 1
    end
  end
end
