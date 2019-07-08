require 'rails_helper'

RSpec.describe Administrator::Biddings::FailsController, type: :controller do
  let(:covenant) { create(:covenant) }
  let(:user) { create(:admin) }
  let(:bidding) { create(:bidding, covenant: covenant) }
  let(:service_response) { bidding.failure! }
  let(:comment) { 'a comment' }
  let(:event) do
    create(:event_bidding_failure, eventable: bidding, creator: user)
  end

  before do
    allow(BiddingsService::AdminFailure).to receive(:new).
      with(bidding: bidding, creator: user, comment: comment) do
        double('call', call: service_response, event: event)
      end

    oauth_token_sign_in user
  end

  describe '#update' do
    let(:params) { { bidding_id: bidding, comment: comment } }

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
