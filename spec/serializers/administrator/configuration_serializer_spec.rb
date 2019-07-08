require 'rails_helper'

RSpec.describe Administrator::ConfigurationSerializer, type: :serializer do
  let(:object) { create :integration_cooperative_configuration }

  subject { format_json(described_class, object) }

  describe 'attributes' do
    let(:last_importation) do
      I18n.l(object.last_importation, format: :shorter) if object.last_importation
    end

    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'endpoint_url' => object.endpoint_url }
    it { is_expected.to include 'token' => object.token }
    it { is_expected.to include 'schedule' => object.schedule }
    it { is_expected.to include 'type' => 'cooperative' }
    it { is_expected.to include 'status' => object.status }
    it { is_expected.to include 'last_importation' => last_importation }
    it { is_expected.to include 'log' => object.log }
  end
end
