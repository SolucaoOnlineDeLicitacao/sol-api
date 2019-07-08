require 'rails_helper'

RSpec.describe BiddingsService::Cancel, type: :service do
  let(:bidding) { create(:bidding, status: 1) }
  let(:service) { described_class.new(bidding: bidding) }
  let!(:api_response) { double('api_response', success?: true) }
  let(:endpoint) { Blockchain::Bidding::Base::ENDPOINT + "/#{bidding.id}" }

  before do
    stub_request(:put, endpoint)

    allow(RecalculateQuantityService).
      to receive(:call!).with(covenant: bidding.covenant).and_return(true)
  end

  describe '#initialize' do
    it { expect(service.bidding).to eq bidding }
  end

  describe '.call' do
    subject(:service_call) { service.call }

    context 'when return success' do
      before do
        allow(Blockchain::Bidding::Update).to receive(:call) { api_response }
        allow(Notifications::Biddings::CancellationRequests::Approved).to receive(:call).with(bidding).and_call_original
        service_call
      end

      describe 'the notification' do
        it { expect(Notifications::Biddings::CancellationRequests::Approved).to have_received(:call).with(bidding) }
      end

      it { expect(bidding.reload.canceled?).to be_truthy }
      it { expect(bidding.lots.map(&:canceled?)).to eq [true] }
      it do
        expect(RecalculateQuantityService).
          to have_received(:call!).with(covenant: bidding.covenant)
      end
    end

    context 'when bidding return RecordInvalid error' do
      before do
        allow(bidding).to receive(:canceled!) { raise ActiveRecord::RecordInvalid }
        allow(Notifications::Biddings::CancellationRequests::Approved).to receive(:call).with(bidding).and_call_original

        service_call
      end

      describe 'the notification' do
        it { expect(Notifications::Biddings::CancellationRequests::Approved).not_to have_received(:call).with(bidding) }
      end

      it { is_expected.to be_falsy }
      it do
        expect(RecalculateQuantityService).
          not_to have_received(:call!).with(covenant: bidding.covenant)
      end
    end

    context 'when bidding return BlockchainError error' do
      let!(:bc_response) { double('bc_response', success?: false) }
      before do
        allow(Blockchain::Bidding::Update).to receive(:call) { bc_response }

        service_call
      end

      it { is_expected.to be_falsy }
      it { expect(bidding.reload.canceled?).to be_falsy }
    end
  end

  describe '.call!' do
    it_behaves_like "Call::WithExceptionsMethods", ActiveRecord::RecordInvalid
  end
end

