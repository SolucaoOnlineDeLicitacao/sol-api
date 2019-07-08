module BiddingsService::Proposals
  class Retry::Lot
    include TransactionMethods
    include Call::WithExceptionsMethods

    delegate :bidding, :concurrent_not_failure, :current_lots,
             :current_lot_ids, to: :proposal

    def main_method
      change_lots_and_proposals_statuses
    end

    def call_exception
      ActiveRecord::RecordInvalid
    end

    private

    def change_lots_and_proposals_statuses
      execute_or_rollback do
        change_proposals_statuses_to_sent!
        change_lots_statuses_to_triage!
        change_next_proposal_status_to_triage! if next_proposal.present?
      end
    end

    def change_proposals_statuses_to_sent!
      concurrent_not_failure.map(&:sent!)
    end

    def change_lots_statuses_to_triage!
      current_lots.map(&:triage!)
    end

    def change_next_proposal_status_to_triage!
      next_proposal.triage!
    end

    def next_proposal
      @next_proposal ||= proposals_for_retry_by_lot.next_proposal
    end

    def proposals_for_retry_by_lot
      bidding.proposals_for_retry_by_lot(current_lot_ids)
    end
  end
end
