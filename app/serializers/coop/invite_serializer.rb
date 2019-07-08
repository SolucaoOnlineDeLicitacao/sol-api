module Coop
  class InviteSerializer < ActiveModel::Serializer
    attributes :id, :status, :bidding_id, :provider_name, :provider_id, :provider_document

    def provider_name
      object.provider.name
    end

    def provider_id
      object.provider.id
    end

    def provider_document
      object.provider.document
    end

    def bidding_id
      object.bidding_id
    end
  end
end
