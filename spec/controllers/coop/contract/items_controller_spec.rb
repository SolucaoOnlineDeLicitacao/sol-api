require 'rails_helper'

RSpec.describe Coop::Contract::ItemsController, type: :controller do
  let(:serializer) { Coop::LotGroupItemSerializer }
  let(:covenant) { create(:covenant) }
  let(:cooperative) { covenant.cooperative }
  let(:user) { create(:user, cooperative: cooperative) }

  let!(:provider) { create(:provider) }
  let!(:supplier) { create(:supplier, provider: provider, name: 'Supplier 1') }
  let!(:bidding) { create(:bidding, status: :finnished, kind: :global, covenant: covenant) }
  let!(:proposal) { create(:proposal, bidding: bidding, provider: provider, status: :accepted) }
  let!(:contract) do
    create(:contract, proposal: proposal,
      user: user, user_signed_at: DateTime.current)
  end

  before { oauth_token_sign_in user }

  describe "GET #index" do
    let(:params) { { contract_id: contract.id } }

    subject(:get_index) { get :index, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'read'
    it_behaves_like 'a scope to' do
      let(:resource) { controller.contract.lot_group_items }
    end

    describe 'JSON' do
      let(:json) { JSON.parse(response.body) }
      let(:items) { proposal.lot_proposals.map(&:lot_group_items).flatten }
      let(:expected_json) { items.map { |item| format_json(serializer, item) } }

      before { get_index }

      describe 'exposes' do
        it { expect(controller.contract.id).to eq contract.id }
      end

      it { expect(response).to have_http_status :ok }
      it { expect(json).to eq expected_json }
    end
  end

end
