require './lib/api_blockchain/client'
require 'rails_helper'

RSpec.describe Administrator::Biddings::ApprovesController, type: :controller do
  let(:user) { create(:admin) }
  let(:bidding) { create(:bidding) }
  let(:service_response) { bidding.approved! }

  before do
    allow(BiddingsService::Approve).
      to receive(:call).with(bidding: bidding) { service_response }

    oauth_token_sign_in user
  end

  describe '#update' do
    let(:params) { { bidding_id: bidding.id } }

    subject(:post_update) { patch :update, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'write'

    it_behaves_like 'a version of', 'post_update', 'bidding'

    describe 'exposes' do
      before { post_update }

      it { expect(controller.bidding).to eq bidding }
    end

    describe 'JSON' do
      before { post_update }

      context 'when updated' do
        it { expect(response).to have_http_status :ok }
      end

      context 'when not updated' do
        let(:service_response) { false }

        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end
end
