require 'rails_helper'

RSpec.describe Coop::Biddings::CancellationRequestsController, type: :controller do
  let(:covenant) { create(:covenant) }
  let(:cooperative) { covenant.cooperative }
  let(:user) { create(:user, cooperative: cooperative) }
  let(:bidding) { create(:bidding, covenant: covenant) }
  let(:event) do
    create(:event_bidding_cancellation_request, eventable: bidding, creator: user)
  end
  let(:service_response) { double('call', call: call_response, event: event) }
  let(:comment) { 'a comment' }
  let(:call_response) { build(:event_bidding_cancellation_request) }

  before do
    allow(BiddingsService::CancellationRequest).to receive(:new).with(
      bidding: bidding,
      comment: comment,
      creator: user
    ) { service_response }

    oauth_token_sign_in user
  end

  describe '#create' do
    let(:params) { { bidding_id: bidding.id, comment: comment } }

    subject(:post_create) { post :create, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'write'

    it_behaves_like 'a version of', 'post_create', 'event'

    describe 'exposes' do
      before { post_create }

      it { expect(controller.bidding).to eq bidding }
    end

    describe 'JSON' do
      before { post_create }

      context 'when updated' do
        it { expect(response).to have_http_status :ok }
      end

      context 'when not updated' do
        let(:call_response) { false }

        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end
end
