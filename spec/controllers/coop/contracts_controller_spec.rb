require 'rails_helper'

RSpec.describe Coop::ContractsController, type: :controller do
  let(:covenant) { create(:covenant) }
  let(:cooperative) { covenant.cooperative }
  let(:user) { create(:user, cooperative: cooperative) }

  let(:bidding) { create(:bidding, covenant: covenant) }

  let(:proposals) { create_list(:proposal, 2, bidding: bidding) }

  let!(:contracts) do
    # creates an array (like create_list) but uses custom proposals
    proposals.map do |proposal|
      create(:contract, proposal: proposal, user: user)
    end
  end

  let(:contract) { contracts.first }

  describe 'BaseContractsController' do
    include_examples 'controllers/concerns/base_contracts_controller' do
      let(:serializer) { Coop::ContractSerializer }
    end

    describe 'load_and_authorize_resource' do
      context 'when calling index method' do
        let(:params) { {} }

        subject(:get_index) { get :index, params: params, xhr: true }

        it_behaves_like 'an user authorization to', 'read'
        it_behaves_like 'a scope to' do
          let(:resource) { controller.current_cooperative.contracts }
        end
      end

      context 'when calling show method' do
        let(:params) { { id: contract } }

        subject(:get_show) { get :show, params: params, xhr: true }

        it_behaves_like 'an user authorization to', 'read'
      end
    end
  end
end
