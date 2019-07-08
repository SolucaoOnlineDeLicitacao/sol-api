require 'rails_helper'

RSpec.describe ClassificationSerializer, type: :serializer do
  let(:object) { create :classification }

  subject { format_json(described_class, object) }

  describe 'attributes' do
    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'name' => object.name }
    it { is_expected.to include 'code' => object.code }
  end

  describe 'associations' do
    describe 'classifiable' do
      let(:provider) { create :provider }
      let(:object) { create :classification, providers: [provider] }
      let(:serialized_provider) { format_json(Administrator::ProviderSerializer, object.providers.first) }
      let(:name_provider) { serialized_provider['name'] }
      let(:document_provider) { serialized_provider['document'] }
      let(:id_provider) { serialized_provider['id'] }

      it { expect(is_expected.as_json['target']['providers'].first['name']).to eq name_provider }
      it { expect(is_expected.as_json['target']['providers'].first['document']).to eq document_provider }
      it { expect(is_expected.as_json['target']['providers'].first['id']).to eq id_provider }
    end
  end

end
