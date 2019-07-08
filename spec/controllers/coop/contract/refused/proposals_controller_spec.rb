require 'rails_helper'

RSpec.describe Coop::Contract::Refused::ProposalsController, type: :controller do
  include_examples 'controller/concerns/refused'

  before { oauth_token_sign_in user }

  describe '#update' do
    let(:params) { { contract_id: contract.id } }

    subject(:post_update) { patch :update, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'write'

    it_behaves_like 'a version of', 'post_update', 'contract'

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }

      before do
        allow(ContractsService::Proposals::Refused).to receive(:call).with(contract: contract) { service_return }
        post_update
      end

      context 'when updated' do
        let(:service_return) { true }

        describe 'exposes' do
          it { expect(controller.contract.id).to eq contract.id }
        end

        it { expect(response).to have_http_status :ok }
        it { expect(ContractsService::Proposals::Refused).to have_received(:call).with(contract: contract) }
      end

      context 'when not updated' do
        let(:service_return) { false }

        it { expect(response).to have_http_status :unprocessable_entity }
        it { expect(json['error']).to be nil }
      end
    end
  end
end
