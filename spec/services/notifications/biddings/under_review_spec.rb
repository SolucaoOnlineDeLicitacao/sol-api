require 'rails_helper'

RSpec.describe Notifications::Biddings::UnderReview, type: :service do
  let!(:bidding)    { create(:bidding, kind: :global, status: :under_review) }
  let(:service)     { described_class.new(bidding) }

  describe 'initialization' do
    it { expect(service.bidding).to eq bidding }
  end

  describe 'call' do
    let(:bidding) { create(:bidding, kind: :global, status: :under_review) }

    describe 'notify' do
      before do
        allow(Notifications::Biddings::UnderReview::Admin).to receive(:call).with(bidding)
        allow(Notifications::Biddings::UnderReview::Cooperative).to receive(:call).with(bidding)
        allow(Notifications::Biddings::UnderReview::Provider).to receive(:call).with(bidding)

        service.call
      end

      it { expect(Notifications::Biddings::UnderReview::Admin).to have_received(:call).with(bidding) }
      it { expect(Notifications::Biddings::UnderReview::Cooperative).to have_received(:call).with(bidding) }
      it { expect(Notifications::Biddings::UnderReview::Provider).to have_received(:call).with(bidding) }
    end
  end
end
