module ProposalService
  class Triage
    include Call::WithExceptionsMethods
    include TransactionMethods

    def main_method
      change_proposal_to_triage
    end

    def call_exception
      ActiveRecord::RecordInvalid
    end

    private

    def change_proposal_to_triage
      execute_or_rollback do
        proposal.triage!
        proposal.reload
        update_proposal_at_blockchain!
      end
    end

    def update_proposal_at_blockchain!
      response = Blockchain::Proposal::Update.call(proposal)
      raise BlockchainError unless response.success?
    end
  end
end
