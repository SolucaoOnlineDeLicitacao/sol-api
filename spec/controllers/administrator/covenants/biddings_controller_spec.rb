require 'rails_helper'

RSpec.describe Administrator::Covenants::BiddingsController, type: :controller do
  let(:serializer) { Coop::BiddingSerializer }
  let(:user) { create :admin }
  let!(:covenant) { create(:covenant) }
  let!(:biddings) { create_list(:bidding, 2, covenant: covenant) }
  let(:bidding) { biddings.first }

  before { oauth_token_sign_in user }

  describe '#index' do
    let(:params) { { covenant_id: covenant } }

    subject(:get_index) { get :index, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'read'
    it_behaves_like 'a scope to' do
      let(:resource) { controller.covenant.biddings }
    end

    describe 'helpers' do
      let!(:params) do
        { covenant_id: covenant, search: 'search', page: 2 }
      end

      let(:exposed_biddings) { Bidding.all }

      before do
        allow(exposed_biddings).to receive(:search) { exposed_biddings }
        allow(exposed_biddings).to receive(:sorted) { exposed_biddings }
        allow(exposed_biddings).to receive(:page).with(anything()).and_call_original
        allow(controller).to receive(:biddings) { exposed_biddings }

        get_index
      end

      it { expect(exposed_biddings).to have_received(:search).with('search') }
      it { expect(exposed_biddings).to have_received(:sorted).with('biddings.created_at', :desc) }
      it { expect(exposed_biddings).to have_received(:page).at_least(:once).with(2) }
      it { expect(described_class::PER_PAGE).to eq 20 }
    end

    describe 'response' do
      before { get_index }

      describe 'http_status' do
        it { expect(response).to have_http_status :ok }
      end

      describe 'exposes' do
        let!(:bidding_0) { create(:bidding, status: 0) }
        it { expect(controller.biddings).to match_array biddings }
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }
        let(:expected_json) { biddings.map { |bidding| format_json(serializer, bidding, scope: user) } }

        it { expect(json).to match_array expected_json }
      end
    end
  end


  describe '#show' do
    let(:params) { { covenant_id: bidding.covenant, id: bidding } }

    subject(:get_show) { get :show, params: params, xhr: true }

    before { get_show }

    it_behaves_like 'an admin authorization to', 'user', 'read'

    describe 'http_status' do
      it { expect(response).to have_http_status :ok }
    end

    describe 'exposes' do
      it { expect(controller.bidding).to eq bidding }
    end

     describe 'JSON' do
      let(:json) { JSON.parse(response.body) }
      let(:expected_json) { format_json(serializer, bidding, scope: user) }

      it { expect(json).to eq expected_json }
    end
  end
end
