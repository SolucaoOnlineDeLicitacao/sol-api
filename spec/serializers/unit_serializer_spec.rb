require 'rails_helper'

RSpec.describe UnitSerializer, type: :serializer do
  let(:object) { create :unit }

  subject { format_json(described_class, object) }

  describe 'attributes' do
    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'name' => object.name }
  end
end
