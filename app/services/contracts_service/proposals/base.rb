module ContractsService
  class Proposals::Base
    include TransactionMethods
    include Call::Methods

    delegate :lot_ids, :proposals_not_draft_or_abandoned, to: :bidding
    delegate :bidding, :proposal, to: :contract

    def main_method
      change_status_fail_and_retry
    end

    private

    def change_status_fail_and_retry
      execute_or_rollback do
        change_contract_status!
        fail_and_retry_proposal!
        update_reopen_reason_contract!
        update_contract_blockchain!
        notify
        update_deleted_at!
      end
    end

    def fail_and_retry_proposal!
      proposal.failure!

      return unless proposals_for_retry_by_lot.present?

      return unless no_more_one_proposal

      BiddingsService::Proposals::Retry.call!(
        bidding: bidding,
        proposal: proposal
      )
    end

    def proposals_for_retry_by_lot
      bidding.proposals_for_retry_by_lot(lot_ids)
    end

    def no_more_one_proposal
      proposals_not_draft_or_abandoned.count > 1
    end

    def update_reopen_reason_contract!
      bidding.update!(reopen_reason_contract: contract)
    end

    def update_contract_blockchain!
      Blockchain::Contract::Update.call!(contract: contract)
    end

    # override
    def update_deleted_at!; end

    # override
    def change_contract_status!; end

    # override for notification
    def notify; end
  end
end
