require 'rails_helper'

RSpec.describe Coop::DashboardsController, type: :controller do

  let(:user) { create :user }
  let!(:cooperative) { user.cooperative }
  let!(:covenant) { create(:covenant, cooperative: cooperative) }
  let!(:providers) { create_list(:provider, 2) }
  let!(:bidding) { create(:bidding, covenant: covenant) }
  let(:biddings) { cooperative.biddings.active.sorted }

  before { oauth_token_sign_in user }

  describe '#show' do
    let(:params) { {} }

    subject(:get_show) { get :show, params: params, xhr: true }

    before do
      allow(::Dashboards::Cooperative).to receive(:new).with(biddings: biddings)
      get_show
    end

    it { expect(::Dashboards::Cooperative).to have_received(:new).with(biddings: biddings) }

    describe 'http_status' do
      it { expect(response).to have_http_status :ok }
    end

    describe 'exposes' do
      before { create(:bidding) }

      it { expect(controller.biddings).to eq biddings }
    end
  end
end
