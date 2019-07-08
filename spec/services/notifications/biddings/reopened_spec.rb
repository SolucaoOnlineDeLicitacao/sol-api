require 'rails_helper'

RSpec.describe Notifications::Biddings::Reopened, type: [:service, :notification] do
  let(:bidding) { create(:bidding, kind: :global) }
  let(:params) { { bidding: bidding } }
  let(:service) { described_class.new(params) }

  describe '#initialize' do
    subject { service }

    it { expect(subject.bidding).to eq bidding }
  end

  describe '.call' do
    subject { described_class.call(params) }

    context 'when it runs successfully' do
      before do
        allow(Notifications::Biddings::Finished).
          to receive(:call).with(bidding)
        allow(Notifications::Proposals::Suppliers::All).
          to receive(:call).with(proposals: bidding.proposals)
        allow(Notifications::Proposals::Suppliers::Segmented).
          to receive(:call).with(proposals: bidding.proposals)

        subject
      end

      context 'when bidding is global' do
        it do
          expect(Notifications::Biddings::Finished).
            to have_received(:call).with(bidding)
        end
        it do
          expect(Notifications::Proposals::Suppliers::All).
            to have_received(:call).with(proposals: bidding.proposals)
        end
        it do
          expect(Notifications::Proposals::Suppliers::Segmented).
            not_to have_received(:call).with(proposals: bidding.proposals)
        end
      end

      context 'when bidding is lot' do
        let(:bidding) { create(:bidding, kind: :lot) }

        it do
          expect(Notifications::Biddings::Finished).
            to have_received(:call).with(bidding)
        end
        it do
          expect(Notifications::Proposals::Suppliers::All).
            not_to have_received(:call).with(proposals: bidding.proposals)
        end
        it do
          expect(Notifications::Proposals::Suppliers::Segmented).
            to have_received(:call).with(proposals: bidding.proposals)
        end
      end
    end
  end
end
