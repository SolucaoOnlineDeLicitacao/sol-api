require 'rails_helper'

RSpec.describe Supp::ContractSerializer, type: :serializer do
  describe 'BaseContractsSerializer' do
    include_examples "serializers/concerns/base_contracts_serializer"
  end

  describe 'custom attributes' do
    let(:object) { create(:contract, :full_signed_at) }
    let(:cooperative_title) { object.user.cooperative.name }

    subject { format_json(described_class, object) }

    describe 'cooperative_title' do
      it { is_expected.to include 'cooperative_title' => cooperative_title }
    end
  end
end
