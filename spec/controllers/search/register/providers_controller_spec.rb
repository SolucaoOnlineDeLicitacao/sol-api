require 'rails_helper'

RSpec.describe Search::Register::ProvidersController, type: :controller do
  let(:serializer) { Administrator::ProviderSerializer }
  let(:admin) { create :admin }

  before { oauth_token_sign_in admin }

  describe '#index' do
    describe 'limit' do
      it { expect(SearchService::Base::LIMIT).to eq 15 }
    end

    describe 'processing' do
      let(:result_arr) { [{ id: provider.id, text: provider.text }].to_json }
      let(:limit) { SearchService::Base::LIMIT }
      let(:json_response) { JSON.load(response.body) }
      let(:params) { { search: { term: search_term } } }

      subject(:get_index) { get :index, params: params, xhr: true }

      context 'with supplier' do
        let!(:provider) { create(:provider) }
        let!(:user) { create(:supplier, provider: provider) }
        let(:search_term) { provider.document }

        before { get_index }

        it { expect(response).to have_http_status :no_content }
        it { expect(json_response).to be_empty }
      end

      context 'without supplier' do
        let!(:provider) { create(:provider, document: 'ABC15') }
        let(:expected_json) { format_json(serializer, provider) }

        context 'and match exactly with document' do
          let(:search_term) { 'ABC15' }

          before { get_index }

          it { expect(response).to have_http_status :ok }
          it { expect(json_response).to eq(expected_json) }
        end

        context 'and did not match with document' do
          let(:search_term) { 'ABC' }

          before { get_index }

          it { expect(response).to have_http_status :ok }
          it { expect(json_response).to be_empty }
        end
      end
    end
  end
end
