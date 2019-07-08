module LotsService
  class Fail
    include Call::WithExceptionsMethods
    include TransactionMethods
    include ProposalService::CancelProposalEventable

    delegate :proposal, :lot, to: :lot_proposal

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
        lot.triage!
        event_cancel_proposal_by_status!
        change_proposals_statuses!
        update_proposal_at_blockchain!
        notify
      end
    end

    def change_proposals_statuses!
      lot&.proposals&.where.not(status: [:draft, :abandoned])&.map(&:sent!)
      lower_sent_proposal&.triage!
      lower_sent_proposal&.reload
    end

    def lower_sent_proposal
      @lower_sent_proposal ||= lot&.proposals&.sent&.lower
    end

    def update_proposal_at_blockchain!
      response = Blockchain::Proposal::Update.call(lower_sent_proposal)
      raise BlockchainError unless response.success?
      proposal.reload
    end

    def notify
      Notifications::Proposals::Lots::Fail.call(proposal, lot, event)
    end
  end
end
