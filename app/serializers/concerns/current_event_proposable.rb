module CurrentEventProposable
  extend ActiveSupport::Concern

  included do
    attributes :id, :status, :bidding_id, :bidding_title,
               :price_total, :current, :comment, :provider,
               :cancel_proposal_refused_comment,
               :cancel_proposal_accepted_comment
  end

  def current
    event_resource.triage?
  end

  def provider
    Administrator::ProviderSerializer.new(object.provider)
  end

  def comment
    current_event&.comment
  end

  def cancel_proposal_refused_comment
    current_cancel_proposal_refused&.comment
  end

  def cancel_proposal_accepted_comment
    current_cancel_proposal_accepted&.comment
  end

  def current_event
    event_resource.event_proposal_status_changes&.changing_to(object.status)&.last
  end

  def current_cancel_proposal_refused
    event_resource.event_cancel_proposal_refuseds&.last
  end

  def current_cancel_proposal_accepted
    event_resource.event_cancel_proposal_accepteds&.last
  end
end
