require 'rails_helper'

RSpec.describe Coop::Contract::PartialExecutionsController, type: :controller do
  let(:covenant)    { create(:covenant) }
  let(:cooperative) { covenant.cooperative }
  let(:user)        { create(:user, cooperative: cooperative) }
  let!(:provider)   { create(:provider) }
  let!(:bidding)    { create(:bidding, status: 6, kind: 3) }

  let!(:proposal) do
    create(:proposal, bidding: bidding, provider: provider, status: :accepted)
  end

  let!(:contract) do
    create(:contract, proposal: proposal, user: user, status: :signed,
                      user_signed_at: DateTime.current)
  end

  let(:lot_group_item) do
    proposal.lot_group_item_lot_proposals.map(&:lot_group_item).first
  end

  let(:returned_lot_group_item) do
    build(:returned_lot_group_item, contract: contract, lot_group_item: lot_group_item)
  end

  before { oauth_token_sign_in user }

  let(:permitted_params) do
    [
      :id, returned_lot_group_items_attributes: [
        :id, :lot_group_item_id, :quantity
      ]
    ]
  end

  describe '#update' do
    let(:quantity) { returned_lot_group_item.quantity.to_s }

    let(:params) do
      {
        contract_id: contract.id, contract: {
          returned_lot_group_items_attributes: [
            {
              quantity: quantity,
              lot_group_item_id: returned_lot_group_item.lot_group_item_id.to_s
            }
          ]
        }, "controller"=>"coop/contract/partial_executions", "action"=>"update"
      }
    end

    let(:params_service) do
      ActionController::Parameters.new(params).require(:contract).permit(permitted_params)
    end

    let(:service_response) { contract.partial_execution! }

    before do
      allow(ContractsService::PartialExecution).
        to receive(:call).
        with(contract: contract, contract_params: params_service) { service_response }
    end

    subject(:post_update) { patch :update, params: params, xhr: true }

    it_behaves_like 'an user authorization to', 'write'

    it_behaves_like 'a version of', 'post_update', 'contract'

    describe 'JSON' do

      let(:json) { JSON.parse(response.body) }

      context 'when updated' do
        before { post_update }

        describe 'exposes' do
          it { expect(controller.contract.id).to eq contract.id }
        end

        it { expect(response).to have_http_status :ok }
        it do
          expect(ContractsService::PartialExecution).
            to have_received(:call).with(contract: contract, contract_params: params_service)
        end
      end

      context 'when not updated' do
        let!(:quantity) { '' }
        let(:errors) { { returned_lot_group_items_errors: [] }.as_json }
        let(:service_response) { false }

        before { post_update }

        it { expect(response).to have_http_status :unprocessable_entity }
        it { expect(json['errors']).to include errors }
      end
    end
  end
end
