require 'rails_helper'
require './lib/api_blockchain/response'
require './lib/api_blockchain/client'

RSpec.describe Blockchain::Proposal::Create do
  let(:proposal) { create(:proposal) }
  let(:lot_proposal) { proposal.lot_proposals.first }
  let(:lot_group_item_lp) { lot_proposal.lot_group_item_lot_proposals.first }

  let!(:service) { Blockchain::Proposal::Create.new(proposal) }

  let(:fake_body) do
    {
      '$class': 'sdc.network.Proposal',
      'proposalId': proposal.id,
      'bidding': "resource:sdc.network.Bidding##{proposal.bidding_id}",
      'biddingId': proposal.bidding_id,
      'providerId': proposal.provider_id,
      'price_total': proposal.price_total.to_f,
      'status': proposal.status.upcase,
      'sent_update_at': proposal.sent_updated_at,
      'lot_proposals': [
        {
          '$class': 'sdc.network.LotProposal',
          'lotId': lot_proposal.lot_id,
          'supplierId': lot_proposal.supplier_id,
          'price_total': lot_proposal.price_total.to_f,
          'delivery_price': lot_proposal.delivery_price.to_f,
          'lot_group_item_lot_proposals': [
            {
              '$class': 'sdc.network.LotGroupItemLotProposal',
              'price': lot_group_item_lp.price.to_f,
              'lotGroupItemId': lot_group_item_lp.lot_group_item.group_item_id,
            }
          ]
        }
      ]
    }
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
    context 'when success request' do
      let(:request) { ApiBlockchain::Response.new(status: 200, body: fake_body) }

      before do
        allow(service).to receive(:request) { request }
        service.call
      end

      it { expect(ApiBlockchain::Client)}

      it { expect(request.success?).to be_truthy }
    end

    context 'when not success request' do
      let(:request) { ApiBlockchain::Response.new(status: 500, body: fake_error_body) }

      before do
        allow(service).to receive(:request) { request }
        service.call
      end

      it { expect(request.success?).to be_falsy }
    end
  end

end
