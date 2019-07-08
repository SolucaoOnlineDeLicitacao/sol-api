require 'rails_helper'

RSpec.describe BiddingsService::Waiting, type: :service do
  let(:bidding) { create(:bidding, status: :draft) }
  let(:params) { { bidding: bidding } }

  before do
    allow(Notifications::Biddings::WaitingApproval).
      to receive(:call).with(bidding).and_return(true)
  end

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.bidding).to eq bidding }
  end

  describe '.call' do
    subject { described_class.call(params) }

    context 'when success' do
      before do
        subject
        bidding.reload
      end

      it { is_expected.to be_truthy }
      it { expect(bidding.waiting?).to be_truthy }
      it { expect(bidding.lots.map(&:waiting?).all?).to be_truthy }
      it do
        expect(Notifications::Biddings::WaitingApproval).
          to have_received(:call).with(bidding)
      end
    end

    context 'when error' do
      context 'and bidding has errors' do
        before do
          allow(bidding).
            to receive(:save!) { raise ActiveRecord::RecordInvalid }

          subject
          bidding.reload
        end

        it { is_expected.to be_falsey }
        it { expect(bidding.waiting?).to be_falsey }
        it { expect(bidding.lots.map(&:waiting?).all?).to be_falsey }
        it do
          expect(Notifications::Biddings::WaitingApproval).
            not_to have_received(:call).with(bidding)
        end
      end

      context 'and bidding is not draft' do
        before do
          bidding.ongoing!

          subject
          bidding.reload
        end

        it { is_expected.to be_falsey }
        it { expect(bidding.waiting?).to be_falsey }
        it { expect(bidding.lots.map(&:waiting?).all?).to be_falsey }
        it do
          expect(Notifications::Biddings::WaitingApproval).
            not_to have_received(:call).with(bidding)
        end
      end
    end
  end
end
