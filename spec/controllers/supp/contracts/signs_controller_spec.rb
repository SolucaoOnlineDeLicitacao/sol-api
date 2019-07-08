require 'rails_helper'

RSpec.describe Supp::Contracts::SignsController, type: :controller do
  let(:covenant) { create(:covenant) }
  let(:cooperative) { covenant.cooperative }
  let(:user) { create(:supplier) }
  let(:provider) { user.provider }
  let(:user_contract) { create(:user, cooperative: cooperative) }

  let!(:provider) { create(:provider) }
  let!(:supplier) { create(:supplier, provider: provider, name: 'Supplier 1') }
  let!(:bidding) { create(:bidding) }
  let!(:proposal) { create(:proposal, bidding: bidding, provider: provider, status: :accepted) }

  let!(:contract) do
    create(:contract, proposal: proposal,
      user: user_contract, user_signed_at: DateTime.current)
  end

  before { oauth_token_sign_in user }

  describe '#update' do
    let(:params) { { contract_id: contract.id } }
    let(:params_service) do
      {
        contract: contract,
        type: 'supplier',
        user: user
      }
    end
    let(:service_response) { contract.signed! }

    before do
      allow(ContractsService::Sign).to receive(:call).with(params_service) { service_response }
      post_update
    end

    subject(:post_update) { patch :update, params: params, xhr: true }

    it_behaves_like 'a supplier authorization to', 'write'

    it_behaves_like 'a version of', 'post_update', 'contract'

    describe 'JSON' do
      context 'when updated' do
        it { expect(response).to have_http_status :ok }
        it { expect(ContractsService::Sign).to have_received(:call).with(params_service) }

        describe 'exposes' do
          it { expect(controller.contract).to eq contract }
        end
      end

      context 'when not updated' do
        let(:service_response) { false }

        it { expect(response).to have_http_status :unprocessable_entity }
        it { expect(ContractsService::Sign).to have_received(:call).with(params_service) }
      end
    end
  end
end
