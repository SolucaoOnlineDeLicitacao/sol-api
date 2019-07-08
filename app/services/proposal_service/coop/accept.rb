module ProposalService::Coop
  class Accept < AcceptBase
    private

    def notify
      Notifications::Proposals::CoopAccepted.call(proposal)
    end
  end
end
