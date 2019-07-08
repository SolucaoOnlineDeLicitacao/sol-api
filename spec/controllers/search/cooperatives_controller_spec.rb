require 'rails_helper'

RSpec.describe Search::CooperativesController, type: :controller do
  let(:user) { create :admin }
  let(:cooperatives) { create_list(:cooperative, 2) }
  let(:cooperative) { cooperatives.first }

  before { oauth_token_sign_in user }

  describe '#index' do
    describe 'limit' do
      it { expect(SearchService::Base::LIMIT).to eq 15 }
    end

    describe 'processing' do
      let(:params) { { search: { term: cooperative.name } } }
      let(:result_arr) { [{ id: cooperative.id, text: cooperative.text }].to_json }

      before do
        allow(Cooperative).to receive(:search).with(cooperative.name, limit).and_call_original
        allow(SearchService::Base).to receive(:call).and_return(result_arr)
        get :index, params: params, xhr: true
      end

      let(:limit) { SearchService::Base::LIMIT }
      let(:json_response) { JSON.load(response.body)[0].to_json }
      let(:expected_result) { { id: cooperative.id, text: cooperative.text }.to_json }

      it { is_expected.to respond_with(:success) }
      it { expect(json_response).to eq(expected_result) }
    end
  end
end
