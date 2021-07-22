require 'rails_helper'

RSpec.describe BiddingsService::UnderReview, type: :service do
  let!(:bidding) { create(:bidding, status: 1) }
  let!(:lot) { bidding.lots.first }
  let!(:lot_triage) { lot.update_attributes(status: :triage) }
  let(:service) { described_class.new(bidding: bidding) }
  let(:draw_service) { OpenStruct.new(has_draw: true, call: true) }

  describe '#initialize' do
    it { expect(service.bidding).to eq bidding }
  end

  describe '.call' do
    before do
      allow(BiddingsService::Review).to receive(:call).and_call_original
      allow(ProposalService::Draw).to receive(:new).with(bidding).and_return(draw_service)
      allow(draw_service).to receive(:call) { true }
      allow(Notifications::Biddings::Draw).to receive(:call).with(bidding: bidding).and_call_original

      service.call
    end

    context 'always' do
      it { expect(ProposalService::Draw).to have_received(:new).with(bidding) }
      it { expect(draw_service).to have_received(:call) }
    end

    context 'when proposals draw' do
      describe 'notification' do
        it { expect(Notifications::Biddings::Draw).to have_received(:call).with(bidding: bidding) }
      end

      it { expect(BiddingsService::Review).not_to have_received(:call).with(bidding: bidding) }
    end

    context 'when proposals not draw' do
      let!(:draw_service) { OpenStruct.new(has_draw: false, call: true) }

      describe 'notification' do
        it { expect(Notifications::Biddings::Draw).not_to have_received(:call).with(bidding: bidding) }
      end

      it { expect(BiddingsService::Review).to have_received(:call).with(bidding: bidding) }
    end
  end

  describe '.call!' do
    before do
      allow(BiddingsService::Review).to receive(:call).and_call_original
      allow(ProposalService::Draw).to receive(:new).with(bidding).and_return(draw_service)
      allow(draw_service).to receive(:call) { true }
      allow(Notifications::Biddings::Draw).to receive(:call).with(bidding: bidding).and_call_original

      service.call!
    end

    context 'always' do
      it { expect(ProposalService::Draw).to have_received(:new).with(bidding) }
      it { expect(draw_service).to have_received(:call) }
    end

    context 'when proposals draw' do
      describe 'notification' do
        it { expect(Notifications::Biddings::Draw).to have_received(:call).with(bidding: bidding) }
      end

      it { expect(BiddingsService::Review).not_to have_received(:call).with(bidding: bidding) }
    end

    context 'when proposals not draw' do
      let!(:draw_service) { OpenStruct.new(has_draw: false, call: true) }

      describe 'notification' do
        it { expect(Notifications::Biddings::Draw).not_to have_received(:call).with(bidding: bidding) }
      end

      it { expect(BiddingsService::Review).to have_received(:call).with(bidding: bidding) }
    end
  end
end
