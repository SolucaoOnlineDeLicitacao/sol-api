require 'rails_helper'

RSpec.describe Notifications::Biddings::FailureAll, type: :service do
  let!(:bidding)    { create(:bidding, kind: :global, status: :failure) }
  let(:params) { { bidding: bidding } }

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.bidding).to eq bidding }
  end

  describe '.call!' do
    let(:bidding) { create(:bidding, kind: :global, status: :failure) }

    subject { described_class.call!(params) }

    describe 'notify' do
      before do
        allow(Notifications::Biddings::Failure::All::Admin).to receive(:call).with(bidding)
        allow(Notifications::Biddings::Failure::All::Provider).to receive(:call).with(bidding)
        allow(Notifications::Biddings::Failure::All::Cooperative).to receive(:call).with(bidding)

        subject
      end

      it { expect(Notifications::Biddings::Failure::All::Admin).to have_received(:call).with(bidding) }
      it { expect(Notifications::Biddings::Failure::All::Provider).to have_received(:call).with(bidding) }
      it { expect(Notifications::Biddings::Failure::All::Cooperative).to have_received(:call).with(bidding) }
    end
  end
end
