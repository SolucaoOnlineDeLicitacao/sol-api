require 'rails_helper'

RSpec.describe Administrator::Covenants::Biddings::Lots::LotProposalsController, type: :controller do
  let(:serializer) { Administrator::LotProposalSerializer }
  let(:covenant) { create(:covenant) }
  let(:cooperative) { covenant.cooperative }
  let(:user) { create(:admin) }

  let!(:biddings) { create_list(:bidding, 2, covenant: covenant) }
  let(:bidding) { biddings.first }
  let(:lots) { bidding.lots }
  let(:lot) { lots.first }

  let(:proposal) { create(:proposal, bidding: bidding, status: :sent) }
  let!(:lot_proposals) { create_list(:lot_proposal, 2, lot: lot, proposal: proposal) }
  let(:lot_proposal) { lot_proposals.first }

  before { oauth_token_sign_in user }

  describe '#index' do
    let(:params) { { covenant_id: covenant, bidding_id: bidding, lot_id: lot, id: lot_proposal } }

    subject(:get_index) { get :index, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'read'
    it_behaves_like 'a scope to' do
      let(:resource) { LotProposal }
    end

    describe 'helpers' do
      let!(:params) do
        { covenant_id: covenant, bidding_id: bidding, lot_id: lot, id: lot_proposal, search: 'search', page: 2 }
      end

      let(:exposed_lot_proposals) do
        LotProposal.joins(:proposal)
          .where.not(proposals: { status: [:draft, :abandoned] })
          .where(lot_proposals: { lot: lot }).all_lower
      end

      before do
        allow(exposed_lot_proposals).to receive(:search) { exposed_lot_proposals }
        allow(exposed_lot_proposals).to receive(:sorted) { exposed_lot_proposals }
        allow(exposed_lot_proposals).to receive(:page).with(anything()).and_call_original
        allow(controller).to receive(:lot_proposals) { exposed_lot_proposals }

        get_index
      end

      it { expect(exposed_lot_proposals).to have_received(:search).with('search') }
      it { expect(exposed_lot_proposals).to have_received(:sorted).with('lot_proposals.price_total', :asc) }
      it { expect(exposed_lot_proposals).to have_received(:page).at_least(:once).with(2) }
      it { expect(described_class::PER_PAGE).to eq 20 }
    end

    describe 'response' do
      before { get_index }

      describe 'http_status' do
        it { expect(response).to have_http_status :ok }
      end

      describe 'exposes' do
        let!(:lot_proposals) do
          LotProposal.joins(:proposal)
            .where.not(proposals: { status: [:draft, :abandoned] })
            .where(lot_proposals: { lot: lot }).all_lower
        end

        it { expect(controller.lot).to eq lot }
        it { expect(controller.lot_proposals).to match_array lot_proposals }
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }
        let(:lot_proposals) do
          LotProposal.joins(:proposal)
            .where.not(proposals: { status: [:draft, :abandoned] })
            .where(lot_proposals: { lot: lot }).all_lower
        end
        let(:expected_json) { lot_proposals.map { |item| format_json(serializer, item) } }

        it { expect(json).to eq expected_json }
      end
    end
  end
end
