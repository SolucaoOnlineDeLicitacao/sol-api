module ProposalService::Admin::LotProposal
  class Accept < ProposalService::Admin::AcceptBase
    delegate :proposal, :lot, to: :lot_proposal

    private

    def change_lots_to_accepted!
      lot.accepted!
    end

    def notify
      Notifications::Proposals::Lots::Accepted.call(proposal, lot)
    end
  end
end
