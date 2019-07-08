require 'rails_helper'

RSpec.describe Search::AdminsController, type: :controller do
  let(:admins) { create_list(:admin, 2) }
  let(:admin) { admins.first }

  before { oauth_token_sign_in admin }

  describe '#index' do
    describe 'limit' do
      it { expect(SearchService::Base::LIMIT).to eq 15 }
    end

    describe 'processing' do
      let(:params) { { search: { term: admin.name } } }
      let(:result_arr) { [{ id: admin.id, text: admin.text }].to_json }

      before do
        allow(Admin).to receive(:search).with(admin.name, limit).and_call_original
        allow(SearchService::Base).to receive(:call).and_return(result_arr)
        get :index, params: params, xhr: true
      end

      let(:limit) { SearchService::Base::LIMIT }
      let(:json_response) { JSON.load(response.body)[0].to_json }
      let(:expected_result) { { id: admin.id, text: admin.text }.to_json }

      it { is_expected.to respond_with(:success) }
      it { expect(json_response).to eq(expected_result) }
    end
  end
end
