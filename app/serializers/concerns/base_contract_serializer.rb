module BaseContractSerializer
  extend ActiveSupport::Concern

  included do
    attributes :id, :title, :status, :price_total, :bidding_title, :provider_title,
               :supplier_signed_at, :user_signed_at, :proposal_id,
               :bidding_kind, :bidding_id, :lot_proposal_ids, :lot_ids, :refused_by_at,
               :refused_by_class, :refused_by_name, :contract_pdf, :deadline, :covenant_name,
               :refused_comment
  end

  def bidding_title
    bidding.title
  end

  def bidding_kind
    bidding.kind
  end

  def bidding_id
    bidding.id
  end

  def lot_proposal_ids
    proposal.lot_proposal_ids
  end

  def lot_ids
    proposal.lot_proposals.map(&:lot_id)
  end

  def provider_title
    proposal.provider.name
  end

  def price_total
    object.proposal_price_total.to_f
  end

  def refused_by_name
    return unless refused_by
    refused_by.name
  end

  def refused_by_class
    return unless refused_by
    refused_by.class.name.underscore
  end

  def supplier_signed_at
    return unless object.supplier_signed_at
    I18n.l(object.supplier_signed_at, format: :shorter)
  end

  def user_signed_at
    return unless object.user_signed_at
    I18n.l(object.user_signed_at, format: :shorter)
  end

  def refused_by_at
    return unless object.refused_by_at
    I18n.l(object.refused_by_at, format: :shorter)
  end

  def contract_pdf
    object.document.try(:file).try(:url)
  end

  def covenant_name
    "#{covenant.number} - #{covenant.name}"
  end

  def refused_comment
    current_refused_event&.comment
  end

  private

  def covenant
    bidding.covenant
  end

  def bidding
    object.bidding
  end

  def proposal
    object.proposal
  end

  def refused_by
    object.refused_by
  end

  def current_refused_event
    object.event_contract_refuseds&.last
  end
end
