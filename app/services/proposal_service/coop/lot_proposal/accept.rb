module ProposalService::Coop::LotProposal
  class Accept < ProposalService::Coop::AcceptBase
    delegate :proposal, :lot, to: :lot_proposal

    private

    def notify
      Notifications::Proposals::Lots::CoopAccepted.call(proposal, lot)
    end
  end
end
