require 'rails_helper'

RSpec.describe Coop::Contract::CompletedsController, type: :controller do
  let(:covenant) { create(:covenant) }
  let(:cooperative) { covenant.cooperative }
  let(:user) { create(:user, cooperative: cooperative) }

  let!(:provider) { create(:provider) }
  let!(:supplier) { create(:supplier, provider: provider, name: 'Supplier 1') }
  let!(:bidding) { create(:bidding, status: 6, kind: 3) }
  let!(:proposal) { create(:proposal, bidding: bidding, provider: provider, status: :accepted) }
  let!(:contract) do
    create(:contract, proposal: proposal, user: user,
                      user_signed_at: DateTime.current)
  end

  before { oauth_token_sign_in user }

  describe '#update' do
    let(:params) { { contract_id: contract.id } }
    let(:service_response) { contract.completed! }

    before do
      allow(ContractsService::Completed).
        to receive(:call).with(contract: contract) { service_response }
    end

    subject(:post_update) { patch :update, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'write'

    it_behaves_like 'a version of', 'post_update', 'contract'

    describe 'JSON' do
      context 'when updated' do
        before { post_update }

        describe 'exposes' do
          it { expect(controller.contract.id).to eq contract.id }
        end

        it { expect(response).to have_http_status :ok }
        it { expect(ContractsService::Completed).to have_received(:call).with(contract: contract) }
      end

      context 'when not updated' do
        let(:service_response) { false }

        before { post_update }

        it { expect(response).to have_http_status :unprocessable_entity }
      end
    end
  end
end
