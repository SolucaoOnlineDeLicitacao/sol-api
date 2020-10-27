module ProposalService::Admin::LotProposal
  class Refuse < ProposalService::Admin::RefuseBase
    delegate :proposal, :lot, to: :lot_proposal

    private

    def refuse_lots!
      lot.failure! if only_allowed_statuses?
    end

    def proposal_status
      lot&.proposals&.pluck(:status).uniq || []
    end

    def notify
      Notifications::Proposals::Lots::Refused.call(proposal, lot)
    end
  end
end
