require 'rails_helper'

RSpec.describe Supp::BiddingsController, type: :controller do
  let(:serializer) { Supp::BiddingSerializer }
  let(:covenant) { create(:covenant) }
  let(:cooperative) { covenant.cooperative }
  let(:user) { create(:supplier) }
  let(:provider) { Provider.find(user.provider_id) }

  let!(:biddings) { create_list(:bidding, 2, covenant: covenant, status: :ongoing) }
  let(:bidding) { biddings.first }

  before { oauth_token_sign_in user }

  describe '#index' do
    let(:params) { {} }

    subject(:get_index) { get :index, params: params, xhr: true }

    it_behaves_like 'a supplier authorization to', 'read'
    it_behaves_like 'a scope to' do
      let(:resource) { Bidding }
    end

    describe 'helpers' do
      let!(:params) do
        { search: 'search', page: 2, sort_column: 'title', sort_direction: 'desc' }
      end

      let(:invites_bidding_id) { provider.bidding_ids }

      let(:exposed_biddings) { Bidding.active }

      before do
        allow(exposed_biddings).to receive(:search) { exposed_biddings }
        allow(exposed_biddings).to receive(:sorted) { exposed_biddings }
        allow(exposed_biddings).to receive(:page).with(anything()).and_call_original
        allow(controller).to receive(:biddings) { exposed_biddings }

        get_index
      end

      it { expect(exposed_biddings).to have_received(:search).with('search') }
      it { expect(exposed_biddings).to have_received(:sorted).with('title', 'desc') }
      it { expect(exposed_biddings).to have_received(:page).at_least(:once).with(2) }
      it { expect(described_class::PER_PAGE).to eq 20 }
    end

    describe 'response' do
      describe 'http_status' do
        before { get_index }

        it { expect(response).to have_http_status :ok }
      end

      describe 'exposes' do
        let(:stub_biddings) { Bidding.all }
        let(:current_ability) { Abilities::SupplierAbility.new(user) }

        before do
          allow(controller).to receive(:current_ability) { current_ability }
  
          allow(Bidding).to receive(:by_provider).with(provider) { stub_biddings }
          allow(stub_biddings).to receive(:accessible_by).with(current_ability) { stub_biddings }
          allow(stub_biddings).to receive(:distinct).with('biddings.id') { Bidding.all }

          get_index
        end

        it { expect(Bidding).to have_received(:by_provider).with(provider) }
        it { expect(stub_biddings).to have_received(:accessible_by).with(current_ability) }
        it { expect(stub_biddings).to have_received(:distinct).with('biddings.id') }
      end

      describe 'JSON' do
        before { get_index }

        let(:json) { JSON.parse(response.body) }
        let(:expected_json) { biddings.map { |bidding| format_json(serializer, bidding) } }

        it { expect(json).to match_array expected_json }
      end
    end
  end

  describe '#show' do
    let(:params) { { id: bidding } }

    before { get_show }

    subject(:get_show) { get :show, params: params, xhr: true }

    it_behaves_like 'a supplier authorization to', 'read'

    describe 'http_status' do
      it { expect(response).to have_http_status :ok }
    end

    describe 'exposes' do
      it { expect(controller.bidding).to eq bidding }
    end

     describe 'JSON' do
      let(:json) { JSON.parse(response.body) }
      let(:expected_json) { format_json(serializer, bidding) }

      it { expect(json).to eq expected_json }
    end
  end
end
