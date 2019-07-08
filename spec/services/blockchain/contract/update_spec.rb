require 'rails_helper'
require './lib/api_blockchain/response'
require './lib/api_blockchain/client'

RSpec.describe Blockchain::Contract::Update do
  include_examples 'services/concerns/init_contract'

  let(:lot_group_item) do
    proposal.lot_group_item_lot_proposals.map(&:lot_group_item).first
  end

  let(:admin) { create(:admin) }
  let!(:provider) { create(:provider) }
  let!(:supplier) { create(:supplier, provider: provider) }

  let!(:contract) do
    create(:contract, proposal: proposal,
      user: user, user_signed_at: DateTime.current,
      supplier: supplier, supplier_signed_at: DateTime.current,
      deleted_at: DateTime.current, refused_by: admin,
      refused_by_at: DateTime.current
    )
  end

  let!(:returned_lot_group_item) do
    create(:returned_lot_group_item, contract: contract, lot_group_item: lot_group_item)
  end

  let!(:service) { described_class.new(contract: contract) }

  let(:fake_body) do
    {
      "$class" => "sdc.network.Contract",
      "contractHash" => contract.id.to_s,
      "bidding" => "resource:sdc.network.Bidding##{contract.bidding.id}",
      "status" => contract.status.upcase,
      "price_total" => contract.proposal.price_total.to_f,
      "supplier_signed_at" => contract.supplier_signed_at,
      "user_signed_at" => contract.user_signed_at,
      "deleted_at" => contract.deleted_at,
      "supplier_id" => contract.supplier_id,
      "user_id" => contract.user_id,
      "proposal" => "resource:sdc.network.Proposal##{contract.proposal_id}",
      "quantity" => contract.lot_group_items.map(&:quantity).sum,
      "refused_by_type" => contract.refused_by_type.upcase,
      "refused_by_id" => contract.refused_by_id.to_s,
      "refused_at" => contract.refused_by_at,
      "returnedLotGroupItems" => lot_group_items_returned
    }
  end

  let(:lot_group_items_returned) do
    contract.lot_group_items_returned.map do |lot_group_item|
      {
        "$class" => "sdc.network.ReturnedLotGroupItem",
        "returnedLotGroupItemId" => lot_group_item.id,
        "quantity" => lot_group_item.quantity,
        "lot_group_item_id" => lot_group_item.lot_id.to_s
      }
    end
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
