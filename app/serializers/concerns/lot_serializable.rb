require './lib/policies/bidding/invite_policy'

module LotSerializable
  extend ActiveSupport::Concern

  included do
    attributes :id, :name, :bidding_id, :bidding_title, :bidding_status, :bidding_kind,
               :bidding_modality, :bidding_draw_at, :lot_group_items_count, :status, :deadline,
               :address, :proposal_status, :proposal_price_total, :invited, :pending,
               :abandoned_proposal, :proposal_importing, :global_proposal_importing,
               :lot_proposals, :provider, :position, :lot_proposal_import_file_url,
               :bidding_proposal_import_file_url

    has_many :lot_group_items, serializer: Supp::LotGroupItemSerializer
    has_many :attachments, serializer: AttachmentSerializer
  end

  def name
    "#{object.position} - #{object.name}"
  end

  def bidding_proposal_import_file_url
    bidding.proposal_import_file&.url
  end

  def lot_proposal_import_file_url
    object.lot_proposal_import_file&.url
  end

  def abandoned_proposal
    all_proposals.abandoned.any?
  end

  def proposal_status
    proposal&.status
  end

  def proposal_price_total
    proposal&.price_total
  end

  def lot_proposals
    proposals.map(&:lot_proposals)&.flatten
  end

  def bidding_kind
    bidding.kind
  end

  def bidding_status
    bidding.status
  end

  def bidding_modality
    bidding.modality
  end

  def bidding_draw_at
    I18n.l(bidding.draw_at)
  end

  def current_provider
    @instance_options[:scope]&.provider
  end

  def provider
    current_provider.as_json
  end

  def bidding_title
    bidding.title
  end

  def invited
    invite_policy.allowed?
  end

  def pending
    invite_policy.pending?
  end

  def proposal_importing
    provider_lot_proposal_imports.active.any?
  end

  def global_proposal_importing
    provider_proposal_imports.active.any?
  end

  private

  def invite_policy
    ::Policies::Bidding::InvitePolicy.new(bidding, current_provider)
  end

  def bidding
    object.bidding
  end

  def all_proposals
    bidding.proposals.where(provider: current_provider)
  end

  def proposals
    object.proposals.where(provider: current_provider)
  end

  def proposal
    proposals.first
  end

  def provider_lot_proposal_imports
    object.lot_proposal_imports.where(provider: current_provider)
  end

  def provider_proposal_imports
    bidding.proposal_imports.where(provider: current_provider)
  end
end
