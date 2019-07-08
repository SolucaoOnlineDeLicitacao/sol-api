require 'rails_helper'

RSpec.describe Supp::Contracts::RefusedsController, type: :controller do
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

  let(:comment) { 'comment' }

  before do
    allow(Notifications::Contracts::Refused).
      to receive(:call).with(contract: contract).and_return(true)

    oauth_token_sign_in user
  end

  describe '#update' do
    let(:params) { { contract_id: contract.id, comment: comment } }
    let(:service_response) { true }

    before { post_update }

    subject(:post_update) { patch :update, params: params, xhr: true }

    it_behaves_like 'a supplier authorization to', 'write'

    it_behaves_like 'a version of', 'post_update', 'contract'

    describe 'JSON' do
      context 'when updated' do
        describe 'exposes' do
          it { expect(controller.contract.id).to eq contract.id }
        end

        it { expect(response).to have_http_status :ok }
      end

      context 'when not updated' do
        let(:service_response) { false }
        let(:comment) { '' }
        let(:json) { JSON.parse(response.body) }
        let(:error_event_key) { ['comment'] }

        it { expect(response).to have_http_status :unprocessable_entity }
        it { expect(json['errors'].keys).to eq error_event_key }
      end
    end
  end
end
