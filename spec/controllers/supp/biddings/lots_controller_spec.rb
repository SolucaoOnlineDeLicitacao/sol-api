require 'rails_helper'

RSpec.describe Supp::Biddings::LotsController, type: :controller do
  let(:serializer) { Supp::LotSerializer }
  let(:covenant) { create(:covenant) }
  let(:cooperative) { covenant.cooperative }
  let(:user) { create(:supplier) }
  let(:provider) { user.supplier }

  let!(:biddings) { create_list(:bidding, 2, covenant: covenant, status: :ongoing) }
  let(:bidding) { biddings.first }
  let(:lots) { bidding.lots }
  let(:lot) { lots.first }

  before { oauth_token_sign_in user }

  describe '#index' do
    let(:params) { { bidding_id: lot.bidding, id: lot } }

    subject(:get_index) { get :index, params: params, xhr: true }

    it_behaves_like 'a supplier authorization to', 'read'
    it_behaves_like 'a scope to' do
      let(:resource) { controller.bidding.lots }
    end

    describe 'helpers' do
      let!(:params) do
        { bidding_id: lot.bidding, id: lot, search: 'search', page: 2, sort_column: 'title', sort_direction: 'desc' }
      end

      let(:exposed_lots) { lots }

      before do
        allow(exposed_lots).to receive(:search) { exposed_lots }
        allow(exposed_lots).to receive(:sorted) { exposed_lots }
        allow(exposed_lots).to receive(:page).with(anything()).and_call_original
        allow(controller).to receive(:lots) { exposed_lots }

        get_index
      end

      it { expect(exposed_lots).to have_received(:search).with('search') }
      it { expect(exposed_lots).to have_received(:sorted).with('title', 'desc') }
      it { expect(exposed_lots).to have_received(:page).at_least(:once).with(2) }
      it { expect(described_class::PER_PAGE).to eq 20 }
    end

    describe 'response' do
      before { get_index }

      describe 'http_status' do
        it { expect(response).to have_http_status :ok }
      end

      describe 'exposes' do
        it { expect(controller.lots).to eq lots }
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }
        let(:expected_json) { lots.map { |lot| format_json(serializer, lot, scope: user) } }

        it { expect(json).to eq expected_json }
      end
    end
  end

  describe '#show' do
    let(:params) { { bidding_id: lot.bidding, id: lot } }

    before { get_show }

    subject(:get_show) { get :show, params: params, xhr: true }

    it_behaves_like 'a supplier authorization to', 'read'

    describe 'http_status' do
      it { expect(response).to have_http_status :ok }
    end

    describe 'exposes' do
      it { expect(controller.lot).to eq lot }
    end

     describe 'JSON' do
      let(:json) { JSON.parse(response.body) }
      let(:expected_json) { format_json(serializer, lot, scope: user) }

      it { expect(json).to eq expected_json }
    end
  end

end
