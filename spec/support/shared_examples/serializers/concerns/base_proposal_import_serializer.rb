RSpec.shared_examples "serializers/concerns/base_proposal_import_serializer" do
  subject { format_json(described_class, object) }

  describe 'attributes' do
    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'provider_id' => object.provider.id }
    it { is_expected.to include 'provider_name' => object.provider.name }
    it { is_expected.to include 'bidding_id' => object.bidding_id }
    it { is_expected.to include 'status' => object.status }
  end
end
