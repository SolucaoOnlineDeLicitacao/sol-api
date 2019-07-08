require 'rails_helper'

RSpec.describe ProviderClassificationSerializer, type: :serializer do
  let(:object) { create :provider_classification }

  subject { format_json(described_class, object) }

  describe 'attributes' do
    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'name' => object.classification.text }
    it { is_expected.to include 'classification_id' => object.classification_id }
    it { is_expected.to include '_destroy' => false }
  end

end
