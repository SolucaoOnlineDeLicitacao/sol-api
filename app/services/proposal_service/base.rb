module ProposalService
  class Base
    private

    def abandoned_and_update_blockchain!
      proposal.abandoned!
      raise BlockchainError unless blockchain_update.success?
      true
    end

    def draft_and_update_blockchain!
      # não criamos/atualizamos/deletamos propostas em rascunho
      return true if proposal.draft?

      proposal.draft!
      raise BlockchainError unless blockchain_update.success?
      true
    end

    def blockchain_delete
      Blockchain::Proposal::Delete.call(proposal)
    end

    def blockchain_update
      Blockchain::Proposal::Update.call(proposal)
    end
  end
end
