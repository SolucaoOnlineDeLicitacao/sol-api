require 'rails_helper'

RSpec.describe BiddingsService::Proposals::Retry, type: :service do
  let(:bidding) { create(:bidding) }
  let!(:proposal) { create(:proposal, bidding: bidding, status: :sent) }
  let(:endpoint) { Blockchain::Bidding::Base::ENDPOINT + "/#{bidding.id}" }
  let(:params) { { bidding: bidding, proposal: proposal } }

  before do
    stub_request(:put, endpoint)
    allow(Blockchain::Bidding::Update).to receive(:call).with(bidding) { api_response }
  end

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.bidding).to eq bidding }
    it { expect(subject.proposal).to eq proposal }
  end

  describe '.call!' do
    subject { described_class.call!(params) }

    context 'when success' do
      before do
        allow(retry_class).to receive(:call!).with(retry_params) { retry_return }
        subject
      end

      let!(:api_response) { double('api_response', success?: true) }
      let!(:retry_class) { BiddingsService::Proposals::Retry::Global }
      let!(:retry_params) { { bidding: bidding } }
      let!(:retry_return) { true }

      it { expect(bidding.reopened?).to be_truthy }
      it { expect(Blockchain::Bidding::Update).to have_received(:call).with(bidding) }

      context 'when bidding global' do
        let(:bidding) { create(:bidding, kind: :global) }

        it { expect(BiddingsService::Proposals::Retry::Global).to have_received(:call!).with(bidding: bidding) }
      end

      context 'when bidding lot' do
        let!(:user) { create(:user) }
        let(:bidding) { create(:bidding, kind: :lot) }
        let(:proposal) { create(:proposal, bidding: bidding, status: :failure) }
        let!(:retry_class) { BiddingsService::Proposals::Retry::Lot }
        let!(:retry_params) { { bidding: bidding, proposal: proposal } }
        let!(:retry_return) { true }

        it { expect(BiddingsService::Proposals::Retry::Lot).to have_received(:call!).with(bidding: bidding, proposal: proposal) }
      end

      context 'when return an expection' do
        context 'when bidding global' do
          let(:bidding) { create(:bidding, kind: :global) }
          let!(:retry_class) { BiddingsService::Proposals::Retry::Global }
          let!(:retry_params) { { bidding: bidding } }
          let!(:retry_return) { ActiveRecord::RecordInvalid }

          it { expect(BiddingsService::Proposals::Retry::Global).to have_received(:call!).with(bidding: bidding) }
        end

        context 'when bidding lot' do
          let(:bidding) { create(:bidding, kind: :lot) }
          let(:proposal) { create(:proposal, bidding: bidding, status: :failure) }
          let!(:retry_class) { BiddingsService::Proposals::Retry::Lot }
          let!(:retry_params) { { bidding: bidding, proposal: proposal } }
          let!(:retry_return) { ActiveRecord::RecordInvalid }

          it { expect(BiddingsService::Proposals::Retry::Lot).to have_received(:call!).with(bidding: bidding, proposal: proposal) }
        end
      end
    end

    context 'when BC raise error' do
      let!(:api_response) { double('api_response', success?: false) }

      it { expect { subject }.to raise_error(ActiveRecord::RecordInvalid) }
      it { expect(bidding.reload.reopened?).to be_falsy }
    end
  end
end
