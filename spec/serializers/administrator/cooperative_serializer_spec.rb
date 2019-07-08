require 'rails_helper'

RSpec.describe Administrator::CooperativeSerializer, type: :serializer do
  let(:object) { create :cooperative }

  subject { format_json(described_class, object) }

  describe 'attributes' do
    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'name' => object.name }
    it { is_expected.to include 'cnpj' => object.cnpj }
  end

  describe 'associations' do
    describe 'address' do
      let(:serialized_address) do
        format_json(AddressSerializer, object.address).except('city')
      end

      it { is_expected.to include 'address' => serialized_address }
    end

    describe 'covenants' do
      let!(:covenant) { create(:covenant, cooperative: object) }

      let(:serialized_covenants) do
        object.covenants.map do |covenant|
          format_json(Administrator::CovenantSerializer, covenant)
        end
      end

      it { is_expected.to include 'covenants' => serialized_covenants }
    end

    describe 'legal_representative' do
      let(:serialized_legal_representative) do
        format_json(LegalRepresentativeSerializer, object.legal_representative)
      end

      it { is_expected.to include 'legal_representative' => serialized_legal_representative }
    end
  end

end
