module ProposalService::Admin
  class Accept < AcceptBase
    delegate :lots, to: :proposal

    private

    def change_lots_to_accepted!
      lots.map(&:accepted!)
    end

    def notify
      Notifications::Proposals::Accepted.call(proposal)
    end
  end
end
