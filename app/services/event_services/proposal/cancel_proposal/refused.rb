module EventServices::Proposal
  class CancelProposal::Refused < EventServices::Proposal::Base

    private

    def proposal_status
      proposal.coop_refused?
    end

    def event_class
      Events::CancelProposalRefused
    end

    def to
      'refused'
    end

    def eventable
      proposal
    end
  end
end
