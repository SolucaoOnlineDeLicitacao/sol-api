module ProposalService::LotProposal
  class Update
    include Call::Methods
    include TransactionMethods
    include ProposalService::ProposalMethods

    def main_method
      lot_proposal_update
    end

    private

    def lot_proposal_update
      execute_or_rollback do
        return proposal_error unless bidding_or_proposal_available?
        lot_proposal.update!(params)
        blockchain_update!
      end
    end

    def blockchain_update!
      # não criamos/atualizamos/deletamos propostas em rascunho
      return true if proposal&.draft?

      response = Blockchain::Proposal::Update.call(proposal)
      raise BlockchainError unless response.success?
    end

    def proposal
      @proposal ||= lot_proposal.proposal
    end
  end
end
