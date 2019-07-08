module ProposalService::ProposalMethods
  def bidding_or_proposal_available?
    bidding_available? || proposal_available?
  end

  def bidding_available?
    bidding.ongoing?
  end

  def proposal_available?
    bidding.draw? && proposal.draw?
  end

  def proposal_error
    proposal.errors.add(:bidding, :can_not_edit)
    false
  end

  def bidding
    @bidding ||= proposal.bidding
  end
end