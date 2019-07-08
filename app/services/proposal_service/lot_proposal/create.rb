module ProposalService::LotProposal
  class Create
    include Call::Methods
    include TransactionMethods

    def main_method
      lot_proposal_create
    end

    private

    def lot_proposal_create
      execute_or_rollback do
        lot_proposal.save!
      end
    end
  end
end
