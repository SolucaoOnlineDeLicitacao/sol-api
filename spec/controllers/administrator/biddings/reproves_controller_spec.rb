require 'rails_helper'

RSpec.describe Administrator::Biddings::ReprovesController, type: :controller do
  let(:covenant) { create(:covenant) }
  let(:cooperative) { covenant.cooperative }
  let(:user) { create(:admin) }

  let!(:bidding) { create(:bidding, status: :waiting, covenant: covenant) }

  before { oauth_token_sign_in user }

  describe '#update' do
    let(:params) do
      {
        bidding_id: bidding.id,
        comment: 'comment'
      }
    end

    subject(:post_update) { patch :update, params: params, xhr: true }

    it_behaves_like 'an admin authorization to', 'user', 'write'

    it_behaves_like 'a version of', 'post_update', 'bidding'

    describe 'exposes' do
      before { post_update }

      it { expect(controller.bidding).to eq bidding }
    end

    describe 'JSON' do
      let(:service_params) do
        { bidding: bidding, comment: params[:comment], user: user }
      end

      let(:service) { BiddingsService::Reprove.new(service_params) }

      before do
        allow(BiddingsService::Reprove).to receive(:new).with(service_params).and_call_original
        allow(service.event).to receive(:errors_as_json) { { comment: :missing } }
        allow(service).to receive(:call) { service_return }
        allow(controller).to receive(:service) { service }

        post_update
      end

      context 'when updated' do
        let!(:service_return) { true }

        it { expect(BiddingsService::Reprove).to have_received(:new).with(service_params) }
        it { expect(service).to have_received(:call) }
        it { expect(response).to have_http_status :ok }
      end

      context 'when not updated' do
        let(:json) { JSON.parse(response.body) }
        let!(:service_return) { false }

        it { expect(BiddingsService::Reprove).to have_received(:new).with(service_params) }
        it { expect(service).to have_received(:call) }
        it { expect(response).to have_http_status :unprocessable_entity }
        it { expect(json['errors']).to be_present }
      end
    end
  end
end
