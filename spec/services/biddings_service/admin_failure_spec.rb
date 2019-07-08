require 'rails_helper'

RSpec.describe BiddingsService::AdminFailure, type: :service do
  let(:covenant) { create(:covenant) }
  let(:user) { create(:admin) }
  let(:lot) { create(:lot) }
  let(:bidding) do
    create(:bidding, covenant: covenant, build_lot: false, lots: [lot])
  end
  let(:comment) { 'a comment' }
  let(:params) { { bidding: bidding, creator: user, comment: comment } }
  let(:event_service_params) do
    { bidding: bidding, comment: comment, creator: user }
  end
  let(:event) do
    create(:event_bidding_failure, eventable: bidding, creator: user)
  end
  let(:event_response) do
    double('event_response', call!: true, event: event)
  end
  let(:bc_response) { double('bc_response', success?: true) }

  before do
    allow(RecalculateQuantityService).
      to receive(:call!).with(covenant: bidding.covenant).and_return(true)
    allow(EventServices::Bidding::Failure).
      to receive(:new).with(event_service_params).and_return(event_response)
    allow(Blockchain::Bidding::Update).
      to receive(:call).and_return(bc_response)
    allow(Notifications::Biddings::Failure).
      to receive(:call).with(bidding).and_return(true)
  end

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.bidding).to eq bidding }
    it { expect(subject.creator).to eq user }
    it { expect(subject.comment).to eq comment }
  end

  describe '.call' do
    subject { described_class.call(params) }

    context 'when success' do
      before { subject }

      it { is_expected.to be_truthy }
      it { expect(bidding.failure?).to be_truthy }
      it { expect(lot.failure?).to be_truthy }
      it do
        expect(RecalculateQuantityService).
          to have_received(:call!).with(covenant: bidding.covenant)
      end
      it do
        expect(EventServices::Bidding::Failure).
          to have_received(:new).with(event_service_params)
      end
      it { expect(Blockchain::Bidding::Update).to have_received(:call) }
      it do
        expect(Notifications::Biddings::Failure).
          to have_received(:call).with(bidding)
      end
    end

    context 'when error' do
      context 'and RecordInvalid' do
        before do
          allow(lot).to receive(:save!) { raise ActiveRecord::RecordInvalid }

          subject
        end

        it { is_expected.to be_falsey }
        it { expect(bidding.failure?).to be_falsey }
        it { expect(lot.reload.failure?).to be_falsey }
        it do
          expect(RecalculateQuantityService).
            not_to have_received(:call!).with(covenant: bidding.covenant)
        end
        it do
          expect(EventServices::Bidding::Failure).
            not_to have_received(:new).with(event_service_params)
        end
        it { expect(Blockchain::Bidding::Update).not_to have_received(:call) }
        it do
          expect(Notifications::Biddings::Failure).
            not_to have_received(:call).with(bidding)
        end
      end

      context 'and recalculate quantity error' do
        before do
          allow(RecalculateQuantityService).
            to receive(:call!).with(covenant: bidding.covenant).
            and_raise(RecalculateItemError)

          subject
        end

        it { is_expected.to be_falsey }
        it { expect(bidding.failure?).to be_falsey }
        it { expect(lot.reload.failure?).to be_falsey }
        it do
          expect(EventServices::Bidding::Failure).
            not_to have_received(:new).with(event_service_params)
        end
        it { expect(Blockchain::Bidding::Update).not_to have_received(:call) }
        it do
          expect(Notifications::Biddings::Failure).
            not_to have_received(:call).with(bidding)
        end
      end

      context 'and event error' do
        before do
          allow(EventServices::Bidding::Failure).
            to receive(:new).with(event_service_params).
            and_raise(ActiveRecord::RecordInvalid)

          subject
        end

        it { is_expected.to be_falsey }
        it { expect(bidding.reload.failure?).to be_falsey }
        it { expect(lot.reload.failure?).to be_falsey }
        it { expect(Blockchain::Bidding::Update).not_to have_received(:call) }
        it do
          expect(Notifications::Biddings::Failure).
            not_to have_received(:call).with(bidding)
        end
      end

      context 'and BlockchainError' do
        let(:bc_response) { double('bc_response', success?: false) }

        before { subject }

        it { is_expected.to be_falsey }
        it { expect(bidding.reload.failure?).to be_falsey }
        it { expect(lot.reload.failure?).to be_falsey }
        it do
          expect(Notifications::Biddings::Failure).
            not_to have_received(:call).with(bidding)
        end
      end
    end
  end

  describe '.call!' do
    it_behaves_like "Call::WithExceptionsMethods", ActiveRecord::RecordInvalid
  end
end
