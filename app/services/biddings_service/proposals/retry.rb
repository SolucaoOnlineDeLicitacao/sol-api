module BiddingsService::Proposals
  class Retry
    include TransactionMethods
    include Call::WithExceptionsMethods

    def main_method
      retry_proposal
    end

    def call_exception
      ActiveRecord::RecordInvalid
    end

    private

    def retry_proposal
      execute_or_rollback do
        # Updates bidding from 'finnished' to 'reopened' again
        bidding.reopened!
        bidding.reload

        proposals_retry!

        update_blockchain
      end
    end

    def proposals_retry!
      return change_global_statuses! if bidding.global?

      change_lot_statuses!
    end

    def change_global_statuses!
      BiddingsService::Proposals::Retry::Global.
        call!(bidding: bidding)
    end

    def change_lot_statuses!
      BiddingsService::Proposals::Retry::Lot.
        call!(bidding: bidding, proposal: proposal)
    end

    def update_blockchain
      response = Blockchain::Bidding::Update.call(bidding)
      raise BlockchainError unless response.success?
    end
  end
end
