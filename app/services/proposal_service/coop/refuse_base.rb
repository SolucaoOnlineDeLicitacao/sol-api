module ProposalService::Coop
  class RefuseBase
    include Call::Methods
    include TransactionMethods

    attr_accessor :event

    def main_method
      change_proposal_to_coop_refused
    end

    private

    def change_proposal_to_coop_refused
      execute_or_rollback do
        return unless proposal.sent? || proposal.triage?

        create_event!
        proposal.coop_refused!
        proposal.reload
        update_proposal_at_blockchain!
        next_proposal_to_triage! if next_proposal
        proposal.reload
        notify
      end
    end

    def create_event!
      @event = build_event
      build_event.save!
    end

    def build_event
      @build_event ||= Events::ProposalStatusChange.new(event_params)
    end

    def event_params
      {
        from: proposal.status,
        to: 'coop_refused',
        comment: comment,
        creator: creator,
        eventable: proposal
      }
    end

    def update_proposal_at_blockchain!
      response = Blockchain::Proposal::Update.call(proposal)
      raise BlockchainError unless response.success?
    end

    def next_proposal_to_triage!
      ProposalService::Triage.call!(proposal: next_proposal)
    end

    # override
    def next_proposal; end

    # override
    def notify; end
  end
end
