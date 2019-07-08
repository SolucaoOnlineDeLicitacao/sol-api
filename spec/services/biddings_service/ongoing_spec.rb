require 'rails_helper'

RSpec.describe BiddingsService::Ongoing, type: :service do
  let!(:bidding) { create(:bidding, status: :approved) }
  let(:params) { { bidding: bidding } }

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.bidding).to eq bidding }
  end

  context 'when calling call method' do
    let(:api_response) { double('api_response', success?: true) }

    before do
      allow(Blockchain::Bidding::Update).
        to receive(:call).with(bidding) { api_response }
      allow(Notifications::Biddings::Ongoing).
        to receive(:call).with(bidding).and_call_original
    end

    describe '.call' do
      subject { described_class.call(params) }

      context 'when changing bidding to ongoing' do
        before { subject }

        it { is_expected.to be_truthy }
        it { expect(bidding.ongoing?).to be_truthy }
        it do
          expect(Blockchain::Bidding::Update).
            to have_received(:call).with(bidding)
        end
        it do
          expect(Notifications::Biddings::Ongoing).
            to have_received(:call).with(bidding)
        end
      end

      context 'when not changing bidding to ongoing' do
        before do
          allow(bidding).
            to receive(:ongoing!) { raise ActiveRecord::RecordInvalid }

          subject
        end

        it { is_expected.to be_falsey }
        it { expect(bidding.ongoing?).to be_falsey }
        it do
          expect(Blockchain::Bidding::Update).
            not_to have_received(:call).with(bidding)
        end
        it do
          expect(Notifications::Biddings::Ongoing).
            not_to have_received(:call).with(bidding)
        end
      end
    end

    describe '.call!' do
      subject { described_class.call!(params) }

      context 'when changing bidding to ongoing' do
        before { subject }

        it { is_expected.to be_truthy }
        it { expect(bidding.ongoing?).to be_truthy }
        it do
          expect(Blockchain::Bidding::Update).
            to have_received(:call).with(bidding)
        end
        it do
          expect(Notifications::Biddings::Ongoing).
            to have_received(:call).with(bidding)
        end
      end

      context 'when not changing bidding to ongoing' do
        before do
          allow(bidding).
            to receive(:ongoing!) { raise ActiveRecord::RecordInvalid }
        end

        it { expect { subject }.to raise_error(ActiveRecord::RecordInvalid) }
      end
    end
  end
end
