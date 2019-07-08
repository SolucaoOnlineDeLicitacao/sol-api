require 'rails_helper'

RSpec.describe Search::UsersController, type: :controller do
  let(:users) { create_list(:user, 2) }
  let(:current_user) { users.first }
  let(:user) { create :admin }

  before { oauth_token_sign_in user }

  describe '#index' do
    describe 'limit' do
      it { expect(SearchService::Base::LIMIT).to eq 15 }
    end

    describe 'processing' do
      let(:params) { { search: { term: current_user.name } } }
      let(:result_arr) { [{ id: current_user.id, text: current_user.text }].to_json }

      before do
        allow(User).to receive(:search).with(current_user.name, limit).and_call_original
        allow(SearchService::Base).to receive(:call).and_return(result_arr)
        get :index, params: params, xhr: true
      end

      let(:limit) { SearchService::Base::LIMIT }
      let(:json_response) { JSON.load(response.body)[0].to_json }
      let(:expected_result) { { id: current_user.id, text: current_user.text }.to_json }

      it { is_expected.to respond_with(:success) }
      it { expect(json_response).to eq(expected_result) }
    end
  end
end
