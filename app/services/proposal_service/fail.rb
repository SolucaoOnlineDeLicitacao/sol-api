module ProposalService
  class Fail
    include Call::WithExceptionsMethods
    include TransactionMethods
    include ProposalService::CancelProposalEventable

    delegate :lots, :bidding, to: :proposal

    attr_accessor :event

    def main_method
      fail
    end

    def call_exception
      ActiveRecord::RecordInvalid
    end

    private

    def fail
      execute_or_rollback do
        return unless available_proposals?

        lots.map(&:triage!)
        event_cancel_proposal_by_status!
        change_proposals_statuses!
        update_proposal_at_blockchain!
        notify
      end
    end

    def change_proposals_statuses!
      bidding&.proposals&.not_failure.not_draft_or_abandoned&.map(&:sent!)
      bidding&.proposals&.sent&.lower&.triage!
      bidding&.proposals&.map(&:reload)
    end

    def update_proposal_at_blockchain!
      proposal.reload

      bidding&.proposals&.not_failure.not_draft_or_abandoned&.each do |current|
        response = Blockchain::Proposal::Update.call(current)
        raise BlockchainError unless response.success?
      end
    end

    def notify
      Notifications::Proposals::Fail.call(proposal, event)
    end

    def available_proposals?
      bidding&.proposals&.not_failure.not_draft_or_abandoned&.count > 0
    end
  end
end
