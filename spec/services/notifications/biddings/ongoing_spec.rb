require 'rails_helper'

RSpec.describe Notifications::Biddings::Ongoing, type: :service do
  let!(:bidding)    { create(:bidding, kind: :global, status: :failure) }
  let(:service)     { described_class.new(bidding) }

  describe 'initialization' do
    it { expect(service.bidding).to eq bidding }
  end

  describe 'call' do
    let(:bidding) { create(:bidding, kind: :global, status: :failure) }

    describe 'notify' do
      before do
        allow(Notifications::Biddings::Ongoing::InvitedProvider).to receive(:call).with(bidding)
        allow(Notifications::Biddings::Ongoing::Cooperative).to receive(:call).with(bidding)
        allow(Notifications::Biddings::Ongoing::ClassificationProvider).to receive(:call).with(bidding)

        service.call
      end

      it { expect(Notifications::Biddings::Ongoing::InvitedProvider).to have_received(:call).with(bidding) }
      it { expect(Notifications::Biddings::Ongoing::Cooperative).to have_received(:call).with(bidding) }
      it { expect(Notifications::Biddings::Ongoing::ClassificationProvider).to have_received(:call).with(bidding) }
    end
  end
end
