module ProposalService::Coop::LotProposal
  class Refuse < ProposalService::Coop::RefuseBase
    delegate :proposal, :lot, to: :lot_proposal

    private

    def next_proposal
      @next_proposal ||= lot&.proposals&.sent&.lower
    end

    def notify
      Notifications::Proposals::Lots::CoopRefused.call(proposal, lot)
    end
  end
end
