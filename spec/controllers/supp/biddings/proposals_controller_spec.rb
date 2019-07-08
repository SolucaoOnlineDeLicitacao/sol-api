require 'rails_helper'

RSpec.describe Supp::Biddings::ProposalsController, type: :controller do
  let(:serializer) { Supp::ProposalSerializer }
  let(:covenant) { create(:covenant) }
  let(:cooperative) { covenant.cooperative }

  let!(:user) { create(:supplier) }
  let!(:provider) { user.provider }
  let!(:invite) { provider.invites.create(bidding: bidding) }
  let!(:proposal) { create(:proposal, bidding: bidding, provider: provider, status: :sent) }
  let(:lot_proposal) { proposal.lot_proposals.first }

  let!(:biddings) { create_list(:bidding, 2, covenant: covenant, status: :finnished) }
  let(:bidding) { biddings.first }
  let(:lot) { bidding.lots.first }
  let(:lot_group_item) { lot.lot_group_items.first }

  before { oauth_token_sign_in user }

  describe '#index' do
    let(:params) { { bidding_id: bidding } }

    subject(:get_index) { get :index, params: params, xhr: true }

    it_behaves_like 'a supplier authorization to', 'read'
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
        it { expect(controller.proposals).to eq bidding.proposals.where.not(status: 0) }
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }
        let(:proposals) { bidding.proposals.where.not(status: 0) }
        let(:expected_json) { proposals.map { |proposal| format_json(serializer, proposal) } }

        it { expect(json).to eq expected_json }
      end
    end
  end

  describe '#show' do
    let(:params) { { bidding_id: bidding, id: proposal } }

    before { get_show }

    subject(:get_show) { get :show, params: params, xhr: true }

    it_behaves_like 'a supplier authorization to', 'read'

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

  describe '#create' do
    let(:params) do
      { proposal: proposal.attributes.except('id'), bidding_id: bidding.id }
    end

    before do
      allow(ProposalService::Create).to receive(:call) { controller.proposal.save!(validate: false) }

      bidding.ongoing!
    end

    subject(:post_create) { post :create, params: params, xhr: true }

    it_behaves_like 'a supplier authorization to', 'write'

    it_behaves_like 'a version of', 'post_create', 'proposal'

    describe 'exposes' do
      before { post_create }

      it { expect(controller.proposal).to be_instance_of Proposal }
      it { expect(controller.bidding).to eq bidding }

      describe '#assign_parents' do
        it { expect(controller.proposal.bidding).to eq bidding }
        it { expect(controller.proposal.provider.id).to eq provider.id }
      end
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      before do
        allow(ProposalService::Create).
          to receive(:call).and_return(service_response)
      end

      context 'when created' do
        let(:service_response) { true }

        before { post_create }

        it { expect(response).to have_http_status :created }
        it { expect(json['proposal']).to be_present }
      end

      context 'when not created' do
        let(:service_response) { false }

        before do
          allow(controller.proposal).
            to receive(:errors_as_json) { { error: 'value' } }

          post_create
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end

  describe '#update' do
    let(:lot_group_item_lot_proposal) do
      build(:lot_group_item_lot_proposal, lot_proposal: lot_proposal,
                                          lot_group_item: lot_group_item,
                                          price: nil)
    end
    let(:params) do
      {
        bidding_id: bidding.id, id: proposal.id, proposal: {
          lot_proposals_attributes: [
            lot_group_item_lot_proposal.lot_proposal.attributes,
            lot_group_item_lot_proposals_attributes: [lot_group_item_lot_proposal.attributes]
          ]
        }
      }
    end

    before do
      allow(ProposalService::Update).to receive(:call) { proposal.update!(price_total: 123) }

      bidding.ongoing!
    end

    subject(:post_update) { patch :update, params: params, xhr: true }

    it_behaves_like 'a supplier authorization to', 'write'

    it_behaves_like 'a version of', 'post_update', 'proposal'

    describe 'exposes' do
      before { post_update }

      it { expect(controller.proposal).to eq proposal }
      it { expect(controller.proposal.sent?).to be_truthy }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when updated' do
        before { post_update }

        it { expect(response).to have_http_status :ok }
        it { expect(json['proposal']).to be_present }
      end

      context 'when not updated' do
        let(:lot_group_item_lot_proposal_errors) do
          {
            "lot_proposals.lot_group_item_lot_proposals.price"=>"invalid",
            "lot_proposals.lot_group_item_lot_proposals.lot_group_item_id"=>"taken",
            "lot_proposals_errors"=>[
              [{}, {"price"=>"invalid", "lot_group_item_id"=>"taken"}]
            ],
            "lot_proposals_error"=>[
              { "lot_group_item_lot_proposals.price"=>"invalid",
                "lot_group_item_lot_proposals.lot_group_item_id"=>"taken" }
            ]
          }
        end

        before do
          allow(ProposalService::Update).to receive(:call).and_call_original

          bidding.ongoing!
          post_update
        end

        it { expect(json['errors']).to include lot_group_item_lot_proposal_errors }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end

  describe '#destroy' do
    let(:params) { { bidding_id: bidding, id: proposal } }
    let(:response_deleted) { double('api_response', success?: blockchain_response_delete) }
    let(:blockchain_response_delete) { true }

    subject(:delete_destroy) { delete :destroy, params: params, xhr: true }

    before do
      allow(Blockchain::Proposal::Delete).
        to receive(:call).with(proposal).and_return(response_deleted)

      bidding.ongoing!
    end

    it_behaves_like 'a supplier authorization to', 'delete'

    it_behaves_like 'a version of', 'delete_destroy', 'proposal'

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      before do
        allow(ProposalService::Destroy).
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
          allow(controller.proposal).to receive(:errors_as_json) { { error: 'value' } }

          delete_destroy
        end

        it { expect(json['errors']).to be_present }
        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end

  describe '#finish' do
    let(:lot_group_item_lot_proposal) do
      build(:lot_group_item_lot_proposal, lot_proposal: lot_proposal,
                                          lot_group_item: lot_group_item,
                                          price: nil)
    end
    let(:params) { { bidding_id: bidding.id, id: proposal.id } }

    subject(:patch_finish) { patch :finish, params: params, xhr: true }

    before { bidding.ongoing! }

    it_behaves_like 'a supplier authorization to', 'write'

    it_behaves_like 'a version of', 'patch_finish', 'proposal'

    describe 'exposes' do
      before do
        allow(ProposalService::Sent).to receive(:call).and_return(true)

        patch_finish
      end

      it { expect(controller.proposal).to eq proposal }
    end

    describe 'JSON' do
      before do
        allow(ProposalService::Sent).to receive(:call).with(proposal) { finish_return }

        patch_finish
      end

      context 'when success' do
        let!(:finish_return) { true }

        it { expect(response).to have_http_status :ok }
      end

      context 'when failure' do
        let!(:finish_return) { false }

        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end
end
