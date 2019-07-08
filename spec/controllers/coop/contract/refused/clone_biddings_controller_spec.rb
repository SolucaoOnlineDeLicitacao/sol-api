require 'rails_helper'

RSpec.describe Coop::Contract::Refused::CloneBiddingsController, type: :controller do
  include_examples 'controller/concerns/refused'

  before { oauth_token_sign_in user }

  describe '#update' do
    let(:params) { { contract_id: contract.id } }
    let(:service_return) { contract.refused! }

    before do
      allow(ContractsService::Clone::Refused).to receive(:call).with(contract: contract) { service_return }
      allow(DateTime).to receive(:current) { DateTime.new(2018, 1, 1, 0, 0, 0) }

      post_update
    end

    subject(:post_update) { patch :update, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'write'

    it_behaves_like 'a version of', 'post_update', 'contract'

    describe '#updates_deleted_at' do
      it { expect(controller.contract.deleted_at).to eq DateTime.current }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      before do
        allow(ContractsService::Clone::Refused).to receive(:call).with(contract: contract) { service_return }
        post_update
      end

      context 'when updated' do
        describe 'exposes' do
          it { expect(controller.contract.id).to eq contract.id }
        end

        it { expect(response).to have_http_status :ok }
        it { expect(ContractsService::Clone::Refused).to have_received(:call).with(contract: contract) }
      end

      context 'when not updated' do
        let!(:service_return) { false }

        it { expect(response).to have_http_status :unprocessable_entity }
        it { expect(json['error']).to be nil }
      end
    end
  end
end
