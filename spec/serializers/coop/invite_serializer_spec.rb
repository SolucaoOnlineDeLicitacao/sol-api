require 'rails_helper'

RSpec.describe Coop::InviteSerializer, type: :serializer do
  let(:object) { create :invite }

  subject { format_json(described_class, object) }

  describe 'attributes' do
    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'status' => object.status }
    it { is_expected.to include 'bidding_id' => object.bidding_id }
    it { is_expected.to include 'provider_name' => object.provider.name }
    it { is_expected.to include 'provider_id' => object.provider.id }
    it { is_expected.to include 'provider_document' => object.provider.document }
  end
end
