module ProposalService
  class Create
    include Call::WithExceptionsMethods
    include TransactionMethods

    def main_method
      record_and_blockchain_create
    end

    def call_exception
      ActiveRecord::RecordInvalid
    end

    private

    def record_and_blockchain_create
      execute_or_rollback do
        ensure_parent
        ensure_supplier
        proposal.save!
        blockchain_proposal_create unless proposal.draft?
      end
    end

    def ensure_parent
      proposal.bidding = bidding
      proposal.provider = provider
      proposal.status = instance_variable_defined?("@status") ? status : :sent
    end

    def ensure_supplier
      proposal.lot_proposals.map { |lot_proposal| lot_proposal.supplier = user }
    end

    def blockchain_proposal_create
      raise BlockchainError unless blockchain_create.success?
    end

    def blockchain_create
      Blockchain::Proposal::Create.call(proposal)
    end
  end
end
