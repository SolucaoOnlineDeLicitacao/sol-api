require 'rails_helper'

RSpec.describe BiddingsService::Failure, type: :service do
  let(:covenant) { create(:covenant) }
  let(:user) { create(:user) }

  let!(:bidding) { create(:bidding, covenant: covenant) }
  let!(:lot) { create(:lot, bidding: bidding) }
  let(:comment) { 'comment' }
  let(:attributes) do
    {
      bidding: bidding,
      comment: comment,
      creator: user
    }
  end

  let(:event) do
    build(:event_bidding_failure, eventable: bidding, creator: user,
      comment: comment, from: bidding.status, to: 'failure')
  end

  let(:event_service_response) { double('event_service', call: true, event: event) }

  subject { described_class.new(attributes) }

  describe '#initialize' do
    it { expect(subject.bidding).to eq bidding }
    it { expect(subject.comment).to eq comment }
    it { expect(subject.creator).to eq user }
  end

  describe '.call' do
    context 'when success' do
      let(:worker) { Bidding::Minute::PdfGenerateWorker }
      let!(:api_response) { double('api_response', success?: true) }

      before do
        allow(Notifications::Biddings::FailureAll).to receive(:call).with(bidding: bidding) { true }
        allow(RecalculateQuantityService).to receive(:call!).with(covenant: bidding.covenant) { true }
        allow(BiddingsService::Clone).to receive(:call!).with(bidding: bidding) { true }
        allow(Blockchain::Bidding::Update).to receive(:call).with(bidding) { api_response }
        allow(EventServices::Bidding::Failure).to receive(:new).with(attributes) { event_service_response }
        bidding.reload.lots.map(&:failure!)

        subject.call
      end

      it { expect(bidding.reload.failure?).to be_truthy }
      it { expect(Notifications::Biddings::FailureAll).to have_received(:call).with(bidding: bidding) }
      it { expect(Blockchain::Bidding::Update).to have_received(:call).with(bidding) }
      it { expect(worker.jobs.size).to eq(1) }
    end

    context 'when failure' do
      context 'when a lot arent failure' do
        let(:errors_i18n) { [I18n.t('errors.messages.fully_failed_lots')] }
        let(:bidding_errors) { subject.bidding.errors.messages[:lots] }

        before do
          allow(EventServices::Bidding::Failure).to receive(:call).with(attributes) { and_call_original }
          subject.call
        end

        it { expect(bidding_errors).to eq errors_i18n }
        it { expect(bidding.reload.failure?).to be_falsy }
      end

      context 'when not save bidding' do
        before do
          allow(bidding).to receive(:failure!) { raise ActiveRecord::RecordInvalid }
          allow(EventServices::Bidding::Failure).to receive(:call).with(attributes) { and_call_original }
          bidding.reload.lots.map(&:failure!)

          subject.call
        end

        it { expect(bidding.reload.failure?).to be_falsy }
      end

      context 'when not save event' do
        let(:error_event_key) { [:comment] }
        let(:comment) { '' }

        before do
          allow(EventServices::Bidding::Failure).to receive(:new).with(attributes) { event_service_response }
          bidding.reload.lots.map(&:failure!)

          subject.call
        end

        it { expect(bidding.reload.failure?).to be_falsy }
        it { expect(event.errors.messages.keys).to eq error_event_key }
      end

      context 'when not recalculate quantity' do
        before do
          allow(EventServices::Bidding::Failure).to receive(:new).with(attributes) { event_service_response }
          allow(RecalculateQuantityService).to receive(:call!) { raise ActiveRecord::RecordInvalid }
          bidding.reload.lots.map(&:failure!)

          subject.call
        end

        it { expect(bidding.reload.failure?).to be_falsy }
      end

      context 'when not clone bidding' do
        before do
          allow(EventServices::Bidding::Failure).to receive(:new).with(attributes) { event_service_response }
          allow(BiddingsService::Clone).to receive(:call!) { raise ActiveRecord::RecordInvalid }
          bidding.reload.lots.map(&:failure!)

          subject.call
        end

        it { expect(bidding.reload.failure?).to be_falsy }
      end

      context 'when not save blockchain' do
        let!(:api_response) { double('api_response', success?: false) }

        before do
          allow(Blockchain::Bidding::Update).to receive(:call).with(bidding) { api_response }
          allow(EventServices::Bidding::Failure).to receive(:new).with(attributes) { event_service_response }
          bidding.reload.lots.map(&:failure!)

          subject.call
        end

        it { expect(bidding.reload.failure?).to be_falsy }
      end
    end
  end
end
