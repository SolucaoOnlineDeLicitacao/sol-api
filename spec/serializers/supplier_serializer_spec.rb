require 'rails_helper'

RSpec.describe SupplierSerializer, type: :serializer do
  let(:object) { create :supplier }

  subject { format_json(described_class, object) }

  context 'attributes' do
    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'name' => object.name }
    it { is_expected.to include 'email' => object.email }
    it { is_expected.to include 'cpf' => object.cpf }
    it { is_expected.to include 'phone' => object.phone }
    it { is_expected.to include 'provider_id' => object.provider_id }
    it { is_expected.to include 'provider_name' => object.provider_name }
  end
end
