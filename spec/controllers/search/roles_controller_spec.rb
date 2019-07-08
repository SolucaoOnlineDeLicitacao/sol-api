require 'rails_helper'

RSpec.describe Search::RolesController, type: :controller do
  let(:user) { create :admin }
  let(:roles) { create_list(:role, 2) }
  let(:role) { roles.first }

  before { oauth_token_sign_in user }

  describe '#index' do
    describe 'limit' do
      it { expect(SearchService::Base::LIMIT).to eq 15 }
    end

    describe 'processing' do
      let(:params) { { search: { term: role.title } } }
      let(:result_arr) { [{ id: role.id, text: role.text }].to_json }
      
      before do
        allow(Role).to receive(:search).with(role.title, limit).and_call_original
        allow(SearchService::Base).to receive(:call).and_return(result_arr)
        get :index, params: params, xhr: true
      end

      let(:limit) { SearchService::Base::LIMIT }
      let(:json_response) { JSON.load(response.body)[0].to_json }
      let(:expected_result) { { id: role.id, text: role.text }.to_json }

      it { is_expected.to respond_with(:success) }
      it { expect(json_response).to eq(expected_result) }
    end
  end
end
