module BiddingsService::ProposalImports
  class Create
    include TransactionMethods
    include Call::WithAsyncMethods

    def main_method
      create
    end

    def async_method
      ProposalUploadWorker.perform_async(user.id, proposal_import.id)
    end

    private

    def create
      execute_or_rollback do
        ensure_parents!
        proposal_import.save!
      end
    end

    def ensure_parents!
      proposal_import.update!(provider: user.provider, bidding: bidding)
    end
  end
end
