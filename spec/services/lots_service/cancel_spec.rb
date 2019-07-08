require 'rails_helper'

RSpec.describe LotsService::Cancel, type: :service do
  include_examples 'services/concerns/init_contract_lot'

  let(:proposal) { contract.proposal }
  let(:service) { described_class.new(proposal: proposal) }
  let(:endpoint) { Blockchain::Proposal::Base::ENDPOINT + "/#{proposal.id}" }
  let!(:api_response) { double('api_response', success?: true) }
  let(:lot) { proposal.lot_proposals.first.lot.reload }

  before do
    stub_request(:put, endpoint)

    allow(RecalculateQuantityService).
      to receive(:call!).with(covenant: proposal.bidding.covenant).and_return(true)
  end

  describe '#initialize' do
    it { expect(service.proposal).to eq proposal }
  end

  describe '.call' do
    subject(:service_call) { service.call }

    context 'when return success' do
      before do
        allow(Blockchain::Proposal::Update).to receive(:call) { api_response }
        allow(Notifications::Biddings::CancellationRequests::Approved).to receive(:call).with(bidding_lot).and_call_original
        service_call
      end

      it { expect(lot.canceled?).to be_truthy }
      it do
        expect(RecalculateQuantityService).
          to have_received(:call!).with(covenant: proposal.bidding.covenant)
      end
    end

    context 'when return error' do
      context 'when ActiveRecord::RecordInvalid' do
        before do
          allow_any_instance_of(LotsService::Cancel).to receive(:cancel_lot_proposals!) { raise ActiveRecord::RecordInvalid }

          service_call
        end

        it { is_expected.to be_falsy }
        it { expect(proposal.lots.map(&:canceled?).uniq).to eq [false] }
        it do
          expect(RecalculateQuantityService).
            not_to have_received(:call!).with(covenant: proposal.bidding.covenant)
        end
      end

      context 'when BlockchainError' do
        let!(:bc_response) { double('bc_response', success?: false) }

        before do
          allow(Blockchain::Proposal::Update).to receive(:call) { bc_response }

          service_call
        end

        it { is_expected.to be_falsy }
        it { expect(proposal.lots.map(&:canceled?).uniq).to eq [false] }
      end
    end
  end

  describe '.call!' do
    it_behaves_like "Call::WithExceptionsMethods", ActiveRecord::RecordInvalid
  end
end
