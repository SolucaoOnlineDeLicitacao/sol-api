require 'rails_helper'

RSpec.describe Administrator::DashboardsController, type: :controller do
  let(:user) { create :admin }

  before { oauth_token_sign_in user }

  describe '#show' do
    let(:bounds_params) do
      { south: '0.0', west: '0.0', north: '0.0', east: '0.0' }
    end
    let(:params) { { bounds: bounds_params } }
    let(:to_json_response) { { 'foo' => 'bar' } }
    let(:service_response) { double('to_json', to_json: to_json_response) }

    before do
      allow(::Dashboards::Admin).
        to receive(:new).with(admin: user, bounds_params: anything).
        and_return(service_response)

      get_show
    end

    subject(:get_show) { get :show, params: params, xhr: true }

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      it { expect(response).to have_http_status :ok }
      it { expect(json).to eq to_json_response }
      it do
        expect(::Dashboards::Admin).
          to have_received(:new).with(admin: user, bounds_params: anything)
      end
    end
  end
end
