require 'rails_helper'

RSpec.describe Coop::Biddings::AdditivesController, type: :controller do
  let(:covenant) { create(:covenant) }
  let(:cooperative) { covenant.cooperative }
  let(:user) { create(:user, cooperative: cooperative) }
  let(:bidding) { create(:bidding, covenant: covenant, status: :ongoing) }

  before { oauth_token_sign_in user }

  describe '#create' do
    let(:date) { Date.current + 3.months }
    let(:params) { { bidding_id: bidding, additive: { to: date } } }

    subject(:post_create) { post :create, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'write'

    it_behaves_like 'a version of', 'post_create', 'additive'

    describe 'exposes' do
      before { post_create }

      it { expect(controller.additive).to be_instance_of(Additive) }
      it { expect(controller.bidding).to eq bidding }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      context 'when created' do
        before do
          allow(AdditiveService).to receive(:call).and_return(true)

          post_create
        end

        it { expect(controller.additive.bidding).to eq bidding }
        it { expect(response).to have_http_status :created }
        it { expect(json['additive']).to be_present }
      end

      context 'when not created' do
        before do
          allow(AdditiveService).to receive(:call).and_return(false)
          allow(controller.additive).
            to receive(:errors_as_json) { { error: 'value' } }

          post_create
        end

        it { expect(response).to have_http_status :unprocessable_entity }
        it { expect(json['errors']).to be_present }
      end
    end
  end
end
