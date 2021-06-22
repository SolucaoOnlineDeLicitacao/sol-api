require 'rails_helper'

RSpec.describe AddressSerializer, type: :serializer do
  let(:object) { create :address }

  subject { format_json(described_class, object) }

  describe 'attributes' do
    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'longitude' => object.longitude.to_s }
    it { is_expected.to include 'latitude' => object.latitude.to_s }
    it { is_expected.to include 'city_name' => object.city_name }
    it { is_expected.to include 'city_id' => object.city_id }
    it { is_expected.to include 'address' => object.address }
    it { is_expected.to include 'number' => object.number }
    it { is_expected.to include 'neighborhood' => object.neighborhood }
    it { is_expected.to include 'cep' => object.cep }
    it { is_expected.to include 'complement' => object.complement }
    it { is_expected.to include 'reference_point' => object.reference_point }
  end

  describe 'associations' do
    describe 'city' do
      let(:serialized_city) { format_json(CitySerializer, object.city) }

      it { is_expected.to include 'city' => serialized_city }
    end
  end

end
