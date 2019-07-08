module ProposalService
  class Update
    include TransactionMethods
    include Call::Methods
    include ProposalMethods

    def initialize(*args)
      super
      @params = params.merge(additional_params)
    end

    def main_method
      record_and_blockchain_update
    end

    private

    def record_and_blockchain_update
      execute_or_rollback do
        return proposal_error unless bidding_or_proposal_available?

        proposal.update!(params)
        raise BlockchainError unless blockchain_create_or_update.success?
      end
    end

    def additional_params
      return { sent_updated_at: DateTime.current, status: :sent } unless bidding.draw?

      { sent_updated_at: DateTime.current }
    end

    def blockchain_create_or_update
      return Blockchain::Proposal::Create.call(proposal) if proposal.was_draft?

      Blockchain::Proposal::Update.call(proposal)
    end
  end
end
