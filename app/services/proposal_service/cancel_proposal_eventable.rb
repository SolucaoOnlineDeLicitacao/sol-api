module ProposalService::CancelProposalEventable
  def event_cancel_proposal_by_status!
    @event = event_manager.event
    event_manager.call!
  end

  def event_manager
    @event_manager ||= klass_name.constantize.new(event_params)
  end

  def klass_name
    "EventServices::Proposal::CancelProposal::#{event_statuses}"
  end

  def event_statuses
    proposal.coop_accepted? ? "Accepted" : "Refused"
  end

  def event_params
    { proposal: proposal, comment: comment, creator: creator }
  end
end
