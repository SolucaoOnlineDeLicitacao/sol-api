module EventServices::Proposal
  class CancelProposal::Accepted < EventServices::Proposal::Base

    private

    def proposal_status
      proposal.coop_accepted?
    end

    def event_class
      Events::CancelProposalAccepted
    end

    def to
      'refused'
    end

    def eventable
      proposal
    end
  end
end
