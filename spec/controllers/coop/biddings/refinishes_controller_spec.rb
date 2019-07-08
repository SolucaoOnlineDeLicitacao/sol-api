require 'rails_helper'

RSpec.describe Coop::Biddings::RefinishesController, type: :controller do
  let(:user) { create(:user) }
  let(:bidding) { create(:bidding, status: :under_review) }
  let(:service_response) { bidding.finnished! }

  before do
    allow(BiddingsService::Refinish).
      to receive(:call).with(bidding: bidding, user: user) { service_response }

    oauth_token_sign_in user
  end

  describe '#update' do
    let(:params) { { bidding_id: bidding.id } }

    subject(:post_update) { patch :update, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'write'

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
