require 'rails_helper'

RSpec.describe Supp::ContractsController, type: :controller do
  let(:provider) { create(:provider) }
  let(:user) { create(:supplier, provider: provider) }
  let(:bidding) { create(:bidding) }

  let(:proposals) do
    create_list(:proposal, 2, bidding: bidding, provider: provider)
  end

  let!(:contracts) do
    # creates an array (like create_list) but uses custom proposals
    proposals.map do |proposal|
      create(:contract, :full_signed_at, proposal: proposal, supplier: user)
    end
  end

  let(:contract) { contracts.first }

  describe 'BaseContractsController' do
    include_examples 'controllers/concerns/base_contracts_controller' do
      let(:serializer) { Supp::ContractSerializer }
    end

    describe 'load_and_authorize_resource' do
      context 'when calling index method' do
        let(:params) { {} }

        subject(:get_index) { get :index, params: params, xhr: true }

        it_behaves_like 'a supplier authorization to', 'read'
        it_behaves_like 'a scope to' do
          let(:resource) { Contract }
        end
      end

      context 'when calling show method' do
        let(:params) { { id: contract } }

        subject(:get_show) { get :show, params: params, xhr: true }

        it_behaves_like 'a supplier authorization to', 'read'
      end
    end
  end
end
