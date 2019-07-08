require 'rails_helper'

RSpec.describe BiddingsService::CancellationRequests::Approve, type: :service do
  let(:bidding) { create(:bidding) }
  let(:event) do
    create(
      :event_bidding_cancellation_request, eventable: bidding, from: 'approved'
    )
  end
  let(:comment) { 'a comment' }
  let(:params) do
    { bidding: bidding, cancellation_request_id: event.id, comment: comment }
  end

  before do
    allow(BiddingsService::Cancel).
      to receive(:call!).with(bidding: bidding).and_return(true)
  end

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.bidding).to eq bidding }
    it { expect(subject.cancellation_request_id).to eq event.id }
    it { expect(subject.comment).to eq comment }
  end

  describe '.call' do
    subject { described_class.call(params) }

    context 'when success' do
      before do
        subject
        event.reload
      end

      it { is_expected.to be_truthy }
      it { expect(event.comment_response).to eq comment }
      it { expect(event.status).to eq 'approved' }
      it do
        expect(BiddingsService::Cancel).
          to have_received(:call!).with(bidding: bidding)
      end
    end

    context 'when error' do
      context 'and event has errors' do
        before do
          allow_any_instance_of(described_class).
            to receive(:update_event!).and_raise(ActiveRecord::RecordInvalid)

          subject
          event.reload
        end

        it { is_expected.to be_falsey }
        it { expect(event.comment_response).to be_nil }
        it { expect(event.status).to be_blank }
        it do
          expect(BiddingsService::Cancel).
            not_to have_received(:call!).with(bidding: bidding)
        end
      end

      context 'and cancel bidding has errors' do
        before do
          allow(BiddingsService::Cancel).
            to receive(:call!).with(bidding: bidding).
            and_raise(ActiveRecord::RecordInvalid)

          subject
          event.reload
        end

        it { is_expected.to be_falsey }
        it { expect(event.comment_response).to be_nil }
        it { expect(event.status).to be_blank }
      end
    end
  end
end
