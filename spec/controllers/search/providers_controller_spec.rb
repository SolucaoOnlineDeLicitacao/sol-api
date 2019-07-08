require 'rails_helper'

RSpec.describe Search::ProvidersController, type: :controller do
  let(:providers) { create_list(:provider, 2) }
  let(:current_provider) { providers.first }
  let(:admin) { create :admin }

  before { oauth_token_sign_in admin }

  describe '#index' do
    describe 'limit' do
      it { expect(SearchService::Base::LIMIT).to eq 15 }
    end

    describe 'processing' do
      let(:params) { { search: { term: current_provider.name } } }
      let(:result_arr) { [{ id: current_provider.id, text: current_provider.text }].to_json }

      before do
        allow(Provider).to receive(:search).with(current_provider.name, limit).and_call_original
        allow(SearchService::Base).to receive(:call).and_return(result_arr)
        get :index, params: params, xhr: true
      end

      let(:limit) { SearchService::Base::LIMIT }
      let(:json_response) { JSON.load(response.body)[0].to_json }
      let(:expected_result) { { id: current_provider.id, text: current_provider.text }.to_json }

      it { is_expected.to respond_with(:success) }
      it { expect(json_response).to eq(expected_result) }
    end
  end
end
