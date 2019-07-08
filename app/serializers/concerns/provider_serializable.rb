module ProviderSerializable
  extend ActiveSupport::Concern

  included do
    attributes :id, :name, :document, :type, :legal_representative, :blocked

    has_one :address
    has_many :provider_classifications, serializer: ProviderClassificationSerializer
    has_many :attachments, serializer: AttachmentSerializer
    has_many :event_provider_accesses, serializer: EventProviderAccessSerializer
  end

  def legal_representative
    LegalRepresentativeSerializer.new(object.legal_representative)
  end
end
