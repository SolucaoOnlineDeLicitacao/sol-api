require 'rails_helper'

RSpec.describe Supp::Biddings::Lots::LotProposalsController, type: :controller do
  let(:serializer) { Supp::LotProposalSerializer }
  let(:covenant) { create(:covenant) }
  let(:cooperative) { covenant.cooperative }

  let!(:user) { create(:supplier) }
  let!(:provider) { user.provider }
  let!(:invite) { provider.invites.create(bidding: bidding) }

  let!(:biddings) { create_list(:bidding, 2, covenant: covenant, status: :finnished) }
  let(:bidding) { biddings.first }
  let(:lots) { bidding.lots }
  let(:lot) { lots.first }

  let!(:proposal) { create(:proposal, bidding: bidding, provider: provider, status: :sent) }
  let(:lot_proposal) { proposal.lot_proposals.first }
  let(:another_lot_proposal) { create(:lot_proposal, lot: lot, proposal: proposal) }
  let(:lot_proposals) { [lot_proposal, another_lot_proposal] }

  before { oauth_token_sign_in user }

  describe '#index' do
    let(:params) { { bidding_id: lot.bidding, lot_id: lot, id: lot_proposal } }

    subject(:get_index) { get :index, params: params, xhr: true }

    it_behaves_like 'a supplier authorization to', 'read'
    it_behaves_like 'a scope to' do
      let(:resource) { LotProposal }
    end

    describe 'helpers' do
      let!(:params) do
        { bidding_id: lot.bidding, lot_id: lot, id: lot_proposal, search: 'search', page: 2 }
      end

      let(:exposed_lot_proposals) { LotProposal.all }

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
        it { expect(controller.lot_proposals).to match_array lot_proposals }
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }
        let(:lot_proposals) do
          LotProposal.joins(:proposal)
            .where.not(proposals: { status: 0 })
            .where(lot_proposals: { lot: lot }).all_lower
        end
        let(:expected_json) { lot_proposals.map { |lot_proposal| format_json(serializer, lot_proposal) } }

        it { expect(json).to eq expected_json }
      end
    end
  end

  describe '#show' do
    let(:params) { { bidding_id: lot.bidding, lot_id: lot, id: lot_proposal } }

    before { get_show }

    subject(:get_show) { get :show, params: params, xhr: true }

    it_behaves_like 'a supplier authorization to', 'read'

    describe 'http_status' do
      it { expect(response).to have_http_status :ok }
    end

    describe 'exposes' do
      it { expect(controller.lot_proposal).to eq lot_proposal }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }
      let(:expected_json) { format_json(serializer, lot_proposal) }

      it { expect(json).to eq expected_json }
    end
  end

  describe '#create' do
    let(:params) do
      { lot_proposal: lot_proposal.attributes.except('id'),
        bidding_id: bidding.id, lot_id: lot.id }
    end

    subject(:post_create) { post :create, params: params, xhr: true }

    before { bidding.ongoing! }

    it_behaves_like 'a supplier authorization to', 'write'

    it_behaves_like 'a version of', 'post_create', 'lot_proposal'

    describe 'exposes' do
      let(:current_proposal_response) { proposal }

      before do
        allow_any_instance_of(Supp::Biddings::Lots::LotProposalsController).
          to receive(:current_proposal).and_return(current_proposal_response)

        post_create
      end

      it { expect(controller.lot_proposal).to be_an_instance_of(LotProposal) }
      it { expect(controller.bidding).to eq bidding }

      context 'when has not associated bidding' do
        let(:current_proposal_response) { [] }

        it { expect(controller.lot_proposal.proposal.bidding).to eq bidding }
        it { expect(controller.lot_proposal.proposal.provider).to be_present }
        it { expect(controller.lot_proposal.proposal.status).to eq 'draft' }
        it { expect(controller.lot_proposal.supplier).to eq user }
      end

      context 'when has associated bidding' do
        it { expect(controller.lot_proposal.proposal).to eq proposal }
        it { expect(controller.lot_proposal.supplier).to eq user }
      end
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      before do
        allow(ProposalService::LotProposal::Create).
          to receive(:call).and_return(service_response)
      end

      context 'when created' do
        let(:service_response) { true }

        before { post_create }

        it { expect(response).to have_http_status :created }
        it { expect(json['lot_proposal']).to be_present }
      end

      context 'when not created' do
        let(:service_response) { false }

        before do
          allow(controller.lot_proposal).
            to receive(:errors_as_json) { { error: 'value' } }

          post_create
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end

  describe '#update' do
    let(:params) do
      { bidding_id: bidding.id, lot_id: lot.id, id: lot_proposal.id,
        lot_proposal: { delivery_price: 100 } }
    end

    subject(:post_update) { patch :update, params: params, xhr: true }

    before { bidding.ongoing! }

    it_behaves_like 'a supplier authorization to', 'write'

    it_behaves_like 'a version of', 'post_update', 'lot_proposal'

    describe 'exposes' do
      before { post_update }

      it { expect(controller.lot_proposal).to eq lot_proposal }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      before do
        allow(ProposalService::LotProposal::Destroy).
          to receive(:call).and_return(service_response)
      end

      context 'when updated' do
        let(:service_response) { true }

        before { post_update }

        it { expect(response).to have_http_status :ok }
        it { expect(json['lot_proposal']).to be_present }
      end

      context 'when not updated' do
        let(:service_response) { false }

        before do
          allow(controller.lot_proposal).
            to receive(:errors_as_json) { { error: 'value' } }

          post_update
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end

  describe '#destroy' do
    let(:params) do
      { bidding_id: bidding.id, lot_id: lot.id, id: lot_proposal.id }
    end
    let(:response_deleted) { double('api_response', success?: blockchain_response_delete) }
    let(:blockchain_response_delete) { true }

    subject(:delete_destroy) { delete :destroy, params: params, xhr: true }

    before do
      allow(Blockchain::Proposal::Delete).
        to receive(:call).with(proposal).and_return(response_deleted)

      bidding.ongoing!
    end

    it_behaves_like 'a supplier authorization to', 'delete'

    it_behaves_like 'a version of', 'delete_destroy', 'lot_proposal'

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      before do
        allow(ProposalService::LotProposal::Destroy).
          to receive(:call).and_return(service_response)
      end

      context 'when destroyed' do
        let(:service_response) { true }

        before { delete_destroy }

        it { expect(response).to have_http_status :ok }
      end

      context 'when not destroyed' do
        let(:service_response) { false }

        before do
          allow(controller.lot_proposal).
            to receive(:errors_as_json) { { error: 'value' } }

          delete_destroy
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end
end
