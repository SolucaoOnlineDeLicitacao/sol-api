RSpec.shared_examples "a cancellation event request" do
  let(:user) { create(:admin) }
  let(:bidding) { create(:bidding) }
  let(:event) do
    create(:event_bidding_cancellation_request, eventable: bidding, creator: user)
  end
  let(:service_response) { double('call', call: call_response, event: event) }
  let(:comment) { 'a comment' }
  let(:call_response) { event.update!(comment_response: comment) }

  before do
    allow(service).to receive(:new).with(
      bidding: bidding,
      cancellation_request_id: event.id.to_s,
      comment: comment
    ) { service_response }

    oauth_token_sign_in user
  end

  describe '#update' do
    let(:params) do
      {
        bidding_id: bidding.id,
        cancellation_request_id: event.id,
        comment: comment
      }
    end

    subject(:post_update) { patch :update, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'write'

    it_behaves_like 'a version of', 'post_update', 'bidding.event_cancellation_requests'

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
        let(:call_response) { false }

        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end
end
