module ProposalService::Admin
  class RefuseBase
    include Call::Methods
    include TransactionMethods

    ALLOWED_STATUSES = %w(refused abandoned failure).freeze

    def main_method
      change_proposal_to_refused
    end

    private

    def change_proposal_to_refused
      execute_or_rollback do
        proposal.refused! && refuse_lots!
        proposal.reload
        update_proposal_at_blockchain!
        notify
      end
    end

    def only_allowed_statuses?
      proposal_status.all? { |status| ALLOWED_STATUSES.include? status }
    end

    def update_proposal_at_blockchain!
      response = Blockchain::Proposal::Update.call(proposal)
      raise BlockchainError unless response.success?
    end

    # override
    def refuse_lots!; end

    # override
    def notify; end
  end
end
