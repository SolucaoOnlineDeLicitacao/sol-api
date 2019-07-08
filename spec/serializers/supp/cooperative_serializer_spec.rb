require 'rails_helper'

RSpec.describe Supp::CooperativeSerializer, type: :serializer do
  let(:object) { create :cooperative }

  subject { format_json(described_class, object) }

  describe 'attributes' do
    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'name' => object.name }
    it { is_expected.to include 'cnpj' => object.cnpj }
  end

  describe 'associations' do
    describe 'address' do
      let(:serialized_address) { format_json(AddressSerializer, object.address) }

      it { is_expected.to include 'address' => serialized_address }
    end
  end
end
