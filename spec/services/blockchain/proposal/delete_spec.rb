require 'rails_helper'
require './lib/api_blockchain/response'
require './lib/api_blockchain/client'

RSpec.describe Blockchain::Proposal::Delete do
  let(:proposal) { create(:proposal) }
  let(:lot_proposal) { proposal.lot_proposals.first }
  let(:lot_group_item_lp) { lot_proposal.lot_group_item_lot_proposals.first }

  let!(:service) { described_class.new(proposal) }
  let!(:verb) { 'DELETE' }
  let(:fake_error_body) do
    {
      'error': {
        'statusCode': 404,
        'name': 'Error',
        'message': 'transaction returned with failure',
        'stack': 'Error: transaction returned with failure'
      }
    }
  end

  let(:endpoint) { described_class::ENDPOINT + "/#{proposal.id}" }

  describe 'endpoint' do
    it { expect(service.send(:endpoint)).to eq endpoint }
  end

  describe 'params' do
    it { expect(service.send(:params)).to be_nil }
  end

  describe 'call' do
    context 'when success request' do
      let(:request) { ApiBlockchain::Response.new(status: 204, body: nil, verb: verb) }

      before do
        allow(service).to receive(:request) { request }
        service.call
      end

      it { expect(ApiBlockchain::Client)}

      it { expect(request.success?).to be_truthy }
    end

    context 'when not success request' do
      let(:request) { ApiBlockchain::Response.new(status: 404, body: fake_error_body, verb: verb) }

      before do
        allow(service).to receive(:request) { request }
        service.call
      end

      it { expect(request.success?).to be_falsy }
    end
  end

end
