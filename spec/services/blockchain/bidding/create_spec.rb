require 'rails_helper'
require './lib/api_blockchain/response'
require './lib/api_blockchain/client'

RSpec.describe Blockchain::Bidding::Create do
  let(:bidding) { create(:bidding) }
  let(:lot) { bidding.lots.first }
  let(:lot_group_item) { lot.lot_group_items.first }

  let!(:service) { Blockchain::Bidding::Create.new(bidding) }

  let(:fake_body) do
    {
      '$class': 'sdc.network.Bidding',
      'biddingId': bidding.id,
      'title': bidding.title,
      'description': bidding.description,
      'covenantId': bidding.covenant_id,
      'covenantDescription': bidding.covenant.name,
      'deadline': bidding.deadline,
      'start_date': bidding.start_date,
      'closing_date': bidding.closing_date,
      'kind': bidding.kind.upcase,
      'status': bidding.status.upcase,
      'modality': bidding.modality.upcase,
      'draw_end_days': bidding.draw_end_days,
      'draw_at': bidding.draw_at,

      'lots': [
        {
          '$class': 'sdc.network.Lot',
          'lotId': lot.id,
          'name': lot.name,
          'status': lot.status.upcase,
          'lot_group_items': [
            {
              '$class': 'sdc.network.LotGroupItem',
              'quantity': lot_group_item.quantity,
              'groupItemId': lot_group_item.group_item_id
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
