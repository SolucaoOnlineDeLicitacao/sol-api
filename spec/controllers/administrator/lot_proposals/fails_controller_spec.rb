require 'rails_helper'

RSpec.describe Administrator::LotProposals::FailsController, type: :controller do
  let(:user) { create(:admin) }
  let(:proposal) { create(:proposal) }
  let(:lot_proposal) { create(:lot_proposal, proposal: proposal) }
  let(:service_response) { lot_proposal.update!(delivery_price: 1) }
  let(:comment) { 'a comment' }
  let(:event) do
    create(:event_cancel_proposal_accepted, eventable: proposal, creator: user)
  end

  before do
    allow(LotsService::Fail).to receive(:new).
      with(lot_proposal: lot_proposal, creator: user, comment: comment) do
        double('call', call: service_response, event: event)
      end

    oauth_token_sign_in user
  end

  describe '#update' do
    let(:params) { { lot_proposal_id: lot_proposal.id, comment: comment } }

    subject(:post_update) { patch :update, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'write'

    it_behaves_like 'a version of', 'post_update', 'lot_proposal'

    describe 'exposes' do
      before { post_update }

      it { expect(controller.lot_proposal).to eq lot_proposal }
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
