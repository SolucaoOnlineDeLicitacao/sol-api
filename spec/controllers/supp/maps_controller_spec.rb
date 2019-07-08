require 'rails_helper'

RSpec.describe Supp::MapsController, type: :controller do

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
    let(:json) { JSON(response.body) }

    subject(:get_show) { get :show, params: params, xhr: true }

    before { get_show }

    it { expect(json['markers'][0]['text']).to eq provider.name }
    it { expect(json['markers'][1]['text']).to eq cooperativees.first.name }
    it { expect(json['markers'][2]['text']).to eq cooperativees.last.name }

    describe 'http_status' do
      it { expect(response).to have_http_status :ok }
    end
  end
end
