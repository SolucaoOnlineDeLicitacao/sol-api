module ProposalService::Admin
  class Refuse < RefuseBase
    delegate :lots, :bidding, to: :proposal

    private

    def refuse_lots!
      lots.map(&:failure!) if only_allowed_statuses?
    end

    def proposal_status
      active_proposals.pluck(:status).uniq
    end

    def active_proposals
      bidding.proposals.not_draft_or_abandoned
    end

    def notify
      Notifications::Proposals::Refused.call(proposal)
    end
  end
end
