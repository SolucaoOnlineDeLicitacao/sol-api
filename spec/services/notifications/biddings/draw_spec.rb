require 'rails_helper'

RSpec.describe Notifications::Biddings::Draw, type: :service do
  let!(:bidding)    { create(:bidding, kind: :global, status: :draw) }
  let(:service)     { described_class.new(bidding: bidding) }

  describe 'initialization' do
    it { expect(service.bidding).to eq bidding }
  end

  describe 'call' do
    let(:bidding) { create(:bidding, kind: :global, status: :draw) }

    describe 'notify' do
      before do
        allow(Notifications::Biddings::Draw::Admin).to receive(:call).with(bidding)
        allow(Notifications::Biddings::Draw::Cooperative).to receive(:call).with(bidding)
        allow(Notifications::Biddings::Draw::DrawProvider).to receive(:call).with(bidding)
        allow(Notifications::Biddings::Draw::SentProvider).to receive(:call).with(bidding)

        service.call
      end

      it { expect(Notifications::Biddings::Draw::Admin).to have_received(:call).with(bidding) }
      it { expect(Notifications::Biddings::Draw::Cooperative).to have_received(:call).with(bidding) }
      it { expect(Notifications::Biddings::Draw::DrawProvider).to have_received(:call).with(bidding) }
      it { expect(Notifications::Biddings::Draw::SentProvider).to have_received(:call).with(bidding) }
    end
  end
end
