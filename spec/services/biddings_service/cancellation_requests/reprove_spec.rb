require 'rails_helper'

RSpec.describe BiddingsService::CancellationRequests::Reprove, type: :service do
  let(:bidding) { create(:bidding) }
  let(:event) do
    create(:event_bidding_cancellation_request, eventable: bidding, from: from)
  end
  let(:from) { 'approved' }
  let(:comment) { 'a comment' }
  let(:params) do
    { bidding: bidding, cancellation_request_id: event.id, comment: comment }
  end
  let(:bc_response) { double('bc_response', success?: true) }

  before do
    allow(Blockchain::Bidding::Update).
      to receive(:call).and_return(bc_response)
    allow(Notifications::Biddings::CancellationRequests::Reproved).
      to receive(:call).with(bidding).and_return(true)

    bidding.lots.map(&:accepted!)
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

      context 'and from approved' do
        it { is_expected.to be_truthy }
        it { expect(event.comment_response).to eq comment }
        it { expect(event.status).to eq 'reproved' }
        it { expect(bidding.draft?).to be_truthy }
        it { expect(bidding.lots.map(&:draft?).all?).to be_truthy }
        it { expect(Blockchain::Bidding::Update).to have_received(:call) }
        it do
          expect(Notifications::Biddings::CancellationRequests::Reproved).
            to have_received(:call).with(bidding)
        end
      end

      context 'and from ongoing' do
        let(:from) { 'ongoing' }

        it { is_expected.to be_truthy }
        it { expect(event.comment_response).to eq comment }
        it { expect(event.status).to eq 'reproved' }
        it { expect(bidding.draft?).to be_falsey }
        it { expect(bidding.lots.map(&:draft?).all?).to be_falsey }
        it { expect(Blockchain::Bidding::Update).not_to have_received(:call) }
        it do
          expect(Notifications::Biddings::CancellationRequests::Reproved).
            to have_received(:call).with(bidding)
        end
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
        it { expect(bidding.draft?).to be_falsey }
        it { expect(bidding.lots.map(&:draft?).all?).to be_falsey }
        it { expect(Blockchain::Bidding::Update).not_to have_received(:call) }
        it do
          expect(Notifications::Biddings::CancellationRequests::Reproved).
            not_to have_received(:call).with(bidding)
        end
      end

      context 'and bidding has errors' do
        before do
          allow(bidding).
            to receive(:draft!).and_raise(ActiveRecord::RecordInvalid)

          subject
          event.reload
        end

        it { is_expected.to be_falsey }
        it { expect(event.comment_response).to be_nil }
        it { expect(event.status).to be_blank }
        it { expect(bidding.draft?).to be_falsey }
        it { expect(bidding.lots.map(&:draft?).all?).to be_falsey }
        it { expect(Blockchain::Bidding::Update).not_to have_received(:call) }
        it do
          expect(Notifications::Biddings::CancellationRequests::Reproved).
            not_to have_received(:call).with(bidding)
        end
      end

      context 'and BlockchainError' do
        let(:bc_response) { double('bc_response', success?: false) }

        before do
          subject
          bidding.reload
        end

        it { is_expected.to be_falsey }
        it { expect(event.comment_response).to be_nil }
        it { expect(event.status).to be_blank }
        it { expect(bidding.draft?).to be_falsey }
        it { expect(bidding.lots.map(&:draft?).all?).to be_falsey }
        it do
          expect(Notifications::Biddings::CancellationRequests::Reproved).
            not_to have_received(:call).with(bidding)
        end
      end
    end
  end
end
