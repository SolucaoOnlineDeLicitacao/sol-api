module BiddingsService::LotProposalImports
  class Create
    include TransactionMethods
    include Call::WithAsyncMethods

    def main_method
      create
    end

    def async_method
      LotProposalUploadWorker.perform_async(user.id, lot_proposal_import.id)
    end

    private

    def create
      execute_or_rollback do
        ensure_parents!
        lot_proposal_import.save!
      end
    end

    def ensure_parents!
      lot_proposal_import.
        update!(provider: user.provider, bidding: bidding, lot: lot)
    end
  end
end
