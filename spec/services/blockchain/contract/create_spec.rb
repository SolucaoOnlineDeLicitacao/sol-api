require 'rails_helper'
require './lib/api_blockchain/response'
require './lib/api_blockchain/client'

RSpec.describe Blockchain::Contract::Create do
  include_examples 'services/concerns/init_contract'

  let(:lot_group_item) do
    proposal.lot_group_item_lot_proposals.map(&:lot_group_item).first
  end

  let!(:service) { described_class.new(contract: contract) }

  let(:fake_body) do
    {
      "$class" => "sdc.network.Contract",
      "contractHash" => contract.id.to_s,
      "contractId" => contract.id.to_s,
      "bidding" => "resource:sdc.network.Bidding##{contract.bidding.id}",
      "status" => contract.status.upcase,
      "price_total" => contract.proposal.price_total.to_f,
      "user_signed_at" => contract.user_signed_at,
      "user_id" => contract.user_id,
      "proposal" => "resource:sdc.network.Proposal##{contract.proposal_id}",
      "quantity" => contract.lot_group_items.map(&:quantity).sum,
      "returnedLotGroupItems" => lot_group_items_returned
    }
  end

  let(:lot_group_items_returned) do
    contract.lot_group_items_returned.to_a
  end

  let(:fake_error_body) do
    {
      'error': {
        'statusCode': 500,
        'name': 'Error',
        'message': 'transaction returned with failure',
        'stack': 'Error: transaction returned with failure'
      }
    }
  end

  describe 'params' do
    it { expect(service.send(:params)).to eq fake_body }
  end

  describe 'call' do
    subject(:service_call) { service.call! }

    context 'when success request' do
      let(:request) { ApiBlockchain::Response.new(status: 200, body: fake_body) }

      before do
        allow(service).to receive(:request) { request }
        service_call
      end

      it { expect(request.success?).to be_truthy }
    end

    context 'when not success request' do
      let(:request) { ApiBlockchain::Response.new(status: 500, body: fake_error_body) }

      before { allow(service).to receive(:request) { request } }

      it { expect { service_call }.to raise_error(BlockchainError) }
    end
  end
end
