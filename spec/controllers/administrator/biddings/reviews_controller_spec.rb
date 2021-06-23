require 'rails_helper'

RSpec.describe Administrator::Biddings::ReviewsController, type: :controller do
  let(:covenant) { create(:covenant) }
  let(:cooperative) { covenant.cooperative }
  let(:user) { create(:admin) }
  let!(:bidding) { create(:bidding, covenant: covenant) }

  before { oauth_token_sign_in user }

  describe '#update' do
    let(:params) { { bidding_id: bidding } }

    subject(:post_update) { patch :update, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'write'

    it_behaves_like 'a version of', 'post_update', 'bidding'

    describe 'exposes' do
      let(:endpoint) { Blockchain::Bidding::Base::ENDPOINT + "/#{bidding.id}" }

      before do
        stub_request(:put, endpoint)

        post_update
      end

      it { expect(controller.bidding.id).to eq bidding.id }
    end

    describe 'response' do
      before do
        allow(BiddingsService::UnderReview).
          to receive(:call).with(bidding: bidding).and_return(service_response)
      end

      context 'when updated' do
        let(:service_response) { true }

        before { post_update }

        it { expect(response).to have_http_status :ok }
      end

      context 'when not updated' do
        let(:service_response) { false }

        before { post_update }

        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end
end
