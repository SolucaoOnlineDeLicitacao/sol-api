module BaseProposalImportSerializer
  extend ActiveSupport::Concern

  included do
    attributes :id, :provider_id, :provider_name, :bidding_id, :status
  end

  def bidding_id
    object.bidding_id
  end

  def provider_id
    object.provider.id
  end

  def provider_name
    object.provider.name
  end
end
