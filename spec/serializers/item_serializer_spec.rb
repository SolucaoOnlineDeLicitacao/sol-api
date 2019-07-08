require 'rails_helper'

RSpec.describe ItemSerializer, type: :serializer do
  let(:object) { create :item }

  subject { format_json(described_class, object) }

  describe 'attributes' do
    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'code' => object.code }
    it { is_expected.to include 'title' => object.title }
    it { is_expected.to include 'description' => object.description }
    it { is_expected.to include 'unit_id' => object.unit_id }
    it { is_expected.to include 'unit_name' => object.unit_name }
    it { is_expected.to include 'owner_name' => object.owner_name }
    it { is_expected.to include 'classification_id' => object.classification_id }
    it { is_expected.to include 'classification_name' => object.classification_name }
  end
end
