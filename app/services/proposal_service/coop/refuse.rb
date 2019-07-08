module ProposalService::Coop
  class Refuse < RefuseBase
    delegate :bidding, to: :proposal

    private

    def next_proposal
      @next_proposal ||= bidding&.proposals&.where(status: :sent)&.lower
    end

    def notify
      Notifications::Proposals::CoopRefused.call(proposal)
    end
  end
end
