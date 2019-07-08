RSpec.shared_examples "a provider_serializer" do
  let(:object) { create :provider }

  subject { format_json(described_class, object) }

  describe 'attributes' do
    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'name' => object.name }
    it { is_expected.to include 'document' => object.document }
    it { is_expected.to include 'type' => object.type }
    it { is_expected.to include 'blocked' => object.blocked }
  end

  describe 'associations' do
    describe 'address' do
      let(:serialized_address) { format_json(AddressSerializer, object.address).except('city') }

      it { is_expected.to include 'address' => serialized_address }
    end

    describe 'legal_representative' do
      let(:serialized_legal_representative) do
        format_json(LegalRepresentativeSerializer, object.legal_representative)
      end

      it { is_expected.to include 'legal_representative' => serialized_legal_representative }
    end

    describe 'provider_classifications' do
      before { create(:provider_classification, provider: object) }

      let(:serialized_provider_classifications) do
        object.provider_classifications.map do |provider_classification|
          format_json(ProviderClassificationSerializer, provider_classification)
        end
      end

      it { is_expected.to include 'provider_classifications' => serialized_provider_classifications }
    end

    describe 'attachments' do
      before { create(:attachment, attachable: object) }

      let(:serialized_attachments) do
        object.attachments.map { |attachment| format_json(AttachmentSerializer, attachment) }
      end

      it { is_expected.to include 'attachments' => serialized_attachments }
    end

    describe 'event_provider_accesses' do
      before { create(:event_provider_access, eventable: object) }

      let(:serialized_event_provider_accesses) do
        object.event_provider_accesses.map do |event_provider_access|
          format_json(EventProviderAccessSerializer, event_provider_access)
        end
      end

      it { is_expected.to include 'event_provider_accesses' => serialized_event_provider_accesses }
    end
  end
end
