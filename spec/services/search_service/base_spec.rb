require 'rails_helper'

RSpec.describe SearchService::Base, type: :service do
  describe 'call' do
    let!(:provider_1) { create(:provider, type: 'Provider', document: 'ABC93') }
    let(:roles) { create_list(:role, 2) }
    let(:role) { roles.first }

    describe 'limit' do
      it { expect(SearchService::Base::LIMIT).to eq 15 }
    end

    describe 'processing' do
      let(:params) { { search: { term: role.title } } }
      let(:base_resources) { Role }
      let(:service) { SearchService::Base.new(params, base_resources) }
      before do
        allow(Role).to receive(:search).with(role.title, limit).and_call_original
      end
      let!(:return_service) { service.call }

      let(:limit) { SearchService::Base::LIMIT }
      let(:json_response) { JSON.load(return_service)[0].to_json }
      let(:expected_result) { [{ id: role.id, text: role.text }].to_json }

      it { expect(return_service).to eq(expected_result) }
    end

    describe 'with serializer' do
      let(:serializer) { Administrator::ProviderSerializer }
      let(:params) { { search: { term: provider_1.document } } }
      let(:base_resources) { Provider }
      let(:service) { SearchService::Base.new(params, base_resources, Administrator::ProviderSerializer) }

      before do
        allow(Provider).to receive(:search).with(provider_1.document, limit).and_call_original
      end

      let(:limit) { SearchService::Base::LIMIT }
      let!(:return_service) { service.call }
      let(:expected_result) { format_json(serializer, provider_1) }

      it { expect(return_service).to eq [expected_result] }
    end
  end
end
