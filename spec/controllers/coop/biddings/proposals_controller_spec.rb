require 'rails_helper'

RSpec.describe Coop::Biddings::ProposalsController, type: :controller do
  let(:serializer) { Coop::ProposalSerializer }
  let(:covenant) { create(:covenant) }
  let(:cooperative) { covenant.cooperative }
  let!(:user) { create(:user, cooperative: cooperative) }
  let!(:provider) { create(:provider) }
  let!(:proposal) { create(:proposal, bidding: bidding, provider: provider, status: :sent) }
  let(:lot_proposal) { proposal.lot_proposals.first }

  let!(:biddings) { create_list(:bidding, 2, covenant: covenant) }
  let(:bidding) { biddings.first }
  let(:lot) { bidding.lots.first }
  let(:lot_group_item) { lot.lot_group_items.first }

  before { oauth_token_sign_in user }

  describe '#index' do
    let(:params) { { bidding_id: bidding } }

    subject(:get_index) { get :index, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'read'
    it_behaves_like 'a scope to' do
      let(:resource) { controller.bidding.proposals }
    end

    describe 'helpers' do
      let!(:params) do
        { bidding_id: bidding, search: 'search', page: 2 }
      end

      let(:exposed_proposals) { Proposal.all }

      before do
        allow(exposed_proposals).to receive(:search) { exposed_proposals }
        allow(exposed_proposals).to receive(:sorted) { exposed_proposals }
        allow(exposed_proposals).to receive(:page).with(anything()).and_call_original
        allow(controller).to receive(:proposals) { exposed_proposals }

        get_index
      end

      it { expect(exposed_proposals).to have_received(:search).with('search') }
      it { expect(exposed_proposals).to have_received(:sorted).with('proposals.price_total', :asc) }
      it { expect(exposed_proposals).to have_received(:page).at_least(:once).with(2) }
      it { expect(described_class::PER_PAGE).to eq 20 }
    end

    describe 'response' do
      before { get_index }

      describe 'http_status' do
        it { expect(response).to have_http_status :ok }
      end

      describe 'exposes' do
        it { expect(controller.bidding).to eq bidding }
        it { expect(controller.proposals).to eq bidding.proposals.where.not(status: [:draft, :abandoned]) }
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }
        let(:proposals) { bidding.proposals.where.not(status: [:draft, :abandoned]).all_lower }
        let(:expected_json) { proposals.map { |proposal| format_json(serializer, proposal) } }

        it { expect(json).to eq expected_json }
      end
    end
  end

  describe '#show' do
    let(:params) { { bidding_id: bidding, id: proposal } }

    before { get_show }

    subject(:get_show) { get :show, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'read'

    describe 'http_status' do
      it { expect(response).to have_http_status :ok }
    end

    describe 'exposes' do
      it { expect(controller.bidding).to eq bidding }
      it { expect(controller.proposal).to eq proposal }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }
      let(:options) { { include: { lot_proposals: :lot_group_item_lot_proposals } } }
      let(:expected_json) { format_json(serializer, proposal, options) }

      it { expect(json).to eq expected_json }
    end
  end
end
