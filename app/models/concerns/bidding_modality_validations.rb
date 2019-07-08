module BiddingModalityValidations
  extend ActiveSupport::Concern

  included do
    validate :bidding_modality, on: :update
    validate :proposals_abandoned, on: :create
  end

  def bidding_modality
    if invalid_modality_change?
      errors.add(error_attribute, :invalid_modality_change)
    end
  end

  def proposals_abandoned
    if already_abandoned_proposal?
      errors.add(error_attribute, :already_abandoned_proposal)
    end
  end

  private

  def invalid_modality_change?
    current_bidding.present? &&
    current_bidding.closed_invite? &&
    changed_or_was_abandoned?
  end

  def changed_or_was_abandoned?
    (has_changed? || proposal_has_changed_from_abandoned_status?)
  end

  def has_changed?
    changed? && !current_proposal.status_changed? && !current_proposal.draft? && !current_proposal.draw?
  end

  def proposal_has_changed_from_abandoned_status?
    current_proposal.status_changed? && proposal_status_was_abandoned?
  end

  def proposal_status_was_abandoned?
    current_proposal.status_was == 'abandoned'
  end

  def already_abandoned_proposal?
    current_bidding.present? &&
    current_bidding.closed_invite? &&
    proposals_has_abandoned_status?
  end

  def proposals_has_abandoned_status?
    current_bidding_proposals.map(&:status).include?('abandoned')
  end

  def current_bidding_proposals
    return proposals_by_provider if current_bidding.global?

    lot_proposals_by_current_lots_and_provider
  end

  def proposals_by_provider
    current_proposals.where(provider: current_proposal.provider)
  end

  def lot_proposals_by_current_lots_and_provider
    current_lot_proposals.
      select(:proposal_id, :'proposals.status').
      joins(:proposal).
      where(id: current_proposal.lot_proposal_ids,
            'proposals.provider': current_proposal.provider)
  end

  def current_proposals
    current_bidding.proposals.dup
  end

  def current_lot_proposals
    current_bidding.lot_proposals.dup
  end

  # can come from Proposal or LotProposal
  def current_bidding
    @current_bidding ||= respond_to?(:bidding) ? bidding : proposal.try(:bidding)
  end

  def error_attribute
    @error_attribute ||= respond_to?(:bidding) ? :bidding : :proposal
  end

  def current_proposal
    @current_proposal ||= respond_to?(:status_changed?) ? self : proposal
  end
end
