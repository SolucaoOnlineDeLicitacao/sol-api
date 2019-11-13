require 'rails_helper'

RSpec.describe Supp::DashboardsController, type: :controller do

  let(:user) { create :supplier }
  let!(:provider) { Individual.find user.provider.id }
  let!(:cooperativees) { create_list(:cooperative, 2) }

  let(:covenant) { create(:covenant) }
  let(:cooperative) { covenant.cooperative }

  let!(:biddings) { create_list :bidding, 2, covenant: covenant, status: :ongoing }
  let(:bidding) { biddings.first }

  before { oauth_token_sign_in user }

  describe '#show' do
    let(:params) { {} }

    subject(:get_show) { get :show, params: params, xhr: true }
    
    describe '#initialize' do
      before do
        allow(controller).to receive(:biddings) { biddings }
        allow(::Dashboards::Supplier).to receive(:new).with(biddings: biddings)

        get_show
      end

      it { expect(::Dashboards::Supplier).to have_received(:new).with(biddings: biddings) }
    end

    describe 'http_status' do
      it { expect(response).to have_http_status :ok }
    end

    describe 'exposes' do
      let(:stub_biddings) { Bidding.all }
      let(:current_ability) { Abilities::SupplierAbility.new(user) }

      before do
        allow(controller).to receive(:current_ability) { current_ability }

        allow(Bidding).to receive(:by_provider).with(provider) { stub_biddings }
        allow(stub_biddings).to receive(:accessible_by).with(current_ability) { stub_biddings }
        allow(stub_biddings).to receive(:sorted) { stub_biddings }
        allow(stub_biddings).to receive(:distinct).with('biddings.id') { Bidding.all }

        get_show
      end

      it { expect(Bidding).to have_received(:by_provider).with(provider) }
      it { expect(stub_biddings).to have_received(:accessible_by).with(current_ability) }
      it { expect(stub_biddings).to have_received(:sorted) }
      it { expect(stub_biddings).to have_received(:distinct).with('biddings.id') }
    end
  end
end
