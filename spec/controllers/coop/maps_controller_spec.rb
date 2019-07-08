require 'rails_helper'

RSpec.describe Coop::MapsController, type: :controller do

  let(:user) { create :user }
  let!(:cooperative) { user.cooperative }
  let!(:covenant) { create(:covenant, cooperative: cooperative) }
  let!(:providers) { create_list(:provider, 2) }
  let!(:bidding) { create(:bidding, covenant: covenant) }
  let(:biddings) { cooperative.biddings.active.sorted }

  before { oauth_token_sign_in user }

  describe '#show' do
    let(:params) { {} }
    let(:json) { JSON(response.body) } 

    subject(:get_show) { get :show, params: params, xhr: true }

    before { get_show }

    it { expect(json['markers'][0]['text']).to eq cooperative.name }
    it { expect(json['markers'][1]['text']).to eq providers.first.name }
    it { expect(json['markers'][2]['text']).to eq providers.last.name }

    describe 'http_status' do
      it { expect(response).to have_http_status :ok }
    end
  end
end
