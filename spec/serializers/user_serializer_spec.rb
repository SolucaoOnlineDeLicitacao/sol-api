require 'rails_helper'

RSpec.describe UserSerializer, type: :serializer do
  let(:object) { create :user }

  subject { format_json(described_class, object) }

  context 'attributes' do
    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'name' => object.name }
    it { is_expected.to include 'email' => object.email }
    it { is_expected.to include 'cpf' => object.cpf }
    it { is_expected.to include 'phone' => object.phone }
    it { is_expected.to include 'role_title' => object.role_title }
    it { is_expected.to include 'role_id' => object.role_id }
    it { is_expected.to include 'cooperative_id' => object.cooperative_id }
    it { is_expected.to include 'cooperative_name' => object.cooperative_name }
  end
end
