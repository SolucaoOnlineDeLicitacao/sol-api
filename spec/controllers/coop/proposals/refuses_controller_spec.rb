require 'rails_helper'

RSpec.describe Coop::Proposals::RefusesController, type: :controller do
  let(:covenant) { create(:covenant) }
  let(:user) { create(:user) }
  let(:bidding) { create(:bidding, covenant: covenant) }
  let(:proposal) { create(:proposal, bidding: bidding, status: :sent) }
  let(:service_response) { proposal.coop_refused! }
  let(:comment) { 'a comment' }
  let(:event) do
    create(:event_proposal_status_change, eventable: proposal, creator: user)
  end

  before do
    allow(ProposalService::Coop::Refuse).to receive(:new).
      with(proposal: proposal, creator: user, comment: comment) do
        double('call', call: service_response, event: event)
      end

    oauth_token_sign_in user
  end

  describe '#update' do
    let(:params) { { proposal_id: proposal, comment: comment } }

    subject(:post_update) { patch :update, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'user', 'write'

    it_behaves_like 'a version of', 'post_update', 'proposal'

    describe 'exposes' do
      before { post_update }

      it { expect(controller.proposal).to eq proposal }
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
