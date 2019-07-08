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

    before do
      allow(::Dashboards::Supplier).to receive(:new).with(biddings: Bidding.active.sorted)
      get_show
    end

    it { expect(::Dashboards::Supplier).to have_received(:new).with(biddings: Bidding.active.sorted) }

    describe 'http_status' do
      it { expect(response).to have_http_status :ok }
    end
  end
end
