require 'rails_helper'

RSpec.describe CitySerializer, type: :serializer do
  let(:object) { create :city }

  subject { format_json(described_class, object) }

  describe 'attributes' do
    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'name' => object.name }
    it { is_expected.to include 'state_name' => object.state.name }
  end
end
