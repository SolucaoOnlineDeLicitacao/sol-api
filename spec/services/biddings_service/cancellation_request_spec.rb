require 'rails_helper'

RSpec.describe BiddingsService::CancellationRequest, type: :service do
  let(:user) { create(:user) }
  let(:bidding) { create(:bidding, status: status) }
  let(:status) { :ongoing }
  let(:event) do
    create(:event_bidding_cancellation_request, eventable: bidding)
  end
  let(:comment) { 'a comment' }
  let(:params) { { bidding: bidding, comment: comment, creator: user } }

  before do
    allow(Notifications::Biddings::CancellationRequests::New).
      to receive(:call).with(bidding).and_return(true)
  end

  let(:service) { described_class.new(params) }

  describe '#initialize' do
    subject { service }

    it { expect(subject.bidding).to eq bidding }
    it { expect(subject.comment).to eq comment }
    it { expect(subject.creator).to eq user }
    it do
      expect(subject.event).
        to be_instance_of(Events::BiddingCancellationRequest)
    end
  end

  describe '.call' do
    subject { service.call }

    context 'when success' do
      before { subject }

      context 'and bidding is not approved' do
        it { is_expected.to be_truthy }
        it { expect(bidding.suspended?).to be_falsey }
        it { expect(service.event.from).to eq bidding.status }
        it { expect(service.event.to).to eq 'canceled' }
        it { expect(service.event.comment).to eq comment }
        it { expect(service.event.eventable).to eq bidding }
        it { expect(service.event.creator).to eq user }
        it do
          expect(Notifications::Biddings::CancellationRequests::New).
            to have_received(:call).with(bidding)
        end
      end

      context 'and bidding is approved' do
        let(:status) { :approved }

        it { is_expected.to be_truthy }
        it { expect(bidding.suspended?).to be_truthy }
        it { expect(service.event.from).to eq status.to_s }
        it { expect(service.event.to).to eq 'canceled' }
        it { expect(service.event.comment).to eq comment }
        it { expect(service.event.eventable).to eq bidding }
        it { expect(service.event.creator).to eq user }
        it do
          expect(Notifications::Biddings::CancellationRequests::New).
            to have_received(:call).with(bidding)
        end
      end
    end

    context 'when error' do
      context 'and event has errors' do
        before do
          allow(service.event).
            to receive(:save!).and_raise(ActiveRecord::RecordInvalid)

          subject
        end

        it { is_expected.to be_falsey }
        it { expect(bidding.suspended?).to be_falsey }
        it do
          expect(Notifications::Biddings::CancellationRequests::New).
            not_to have_received(:call).with(bidding)
        end
      end

      context 'and bidding is draft' do
        let(:status) { :draft }

        before { subject }

        it { is_expected.to be_falsey }
        it { expect(bidding.suspended?).to be_falsey }
        it do
          expect(Notifications::Biddings::CancellationRequests::New).
            not_to have_received(:call).with(bidding)
        end
      end
    end
  end
end
