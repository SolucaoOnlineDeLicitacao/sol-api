require 'rails_helper'

RSpec.describe Administrator::LotProposals::RefusesController, type: :controller do
  let(:covenant) { create(:covenant) }
  let(:user) { create(:admin) }
  let(:bidding) { create(:bidding, covenant: covenant) }
  let(:lots) { bidding.lots }
  let(:lot) { lots.first }
  let(:proposal) { create(:proposal, bidding: bidding, status: :sent) }
  let(:lot_proposal) { create(:lot_proposal, lot: lot, proposal: proposal) }
  let(:service_response) { lot_proposal.update!(delivery_price: 1) }

  before do
    allow(ProposalService::Admin::LotProposal::Refuse).
      to receive(:call).with(lot_proposal: lot_proposal) { service_response }

    oauth_token_sign_in user
  end

  describe '#update' do
    let(:params) { { lot_proposal_id: lot_proposal.id } }

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
