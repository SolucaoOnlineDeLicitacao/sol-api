require 'rails_helper'

RSpec.describe BiddingsService::Reprove, type: :service do
  let!(:admin) { create(:admin) }
  let!(:bidding) { create(:bidding, status: :waiting) }
  let(:comment) { 'comment' }

  let(:service) do
    described_class.new(bidding: bidding, comment: comment, user: admin)
  end

  let(:event) do
    build(:event_bidding_reproved, eventable: bidding, creator: admin,
      comment: comment, from: bidding.status, to: 'draft')
  end

  describe '#initialize' do
    it { expect(service.bidding).to eq bidding }
    it { expect(service.comment).to eq comment }
    it { expect(service.user).to eq admin }
    it { expect(service.event).to be_a_new Events::BiddingReproved }
    it { expect(service.event.attributes).to eq event.attributes }
  end

  describe 'call' do
    context 'when success' do
      before do
        # forçando a bidding a ser inválida para testar o update_attribute
        bidding.update_attribute(:deadline, nil)
        allow(Notifications::Biddings::Reproved).to receive(:call).with(bidding).and_call_original

        service.call
      end

      it { expect(service.event).to be_persisted }
      it { expect(bidding.reload.draft?).to be_truthy }
      it { expect(Notifications::Biddings::Reproved).to have_received(:call).with(bidding) }
    end

    context 'when failure' do
      before do
        allow(service.event).to receive(:save!) { raise ActiveRecord::RecordInvalid }
        allow(Notifications::Biddings::Reproved).to receive(:call).with(bidding).and_call_original

        service.call
      end

      it { expect(service.event).not_to be_persisted }
      it { expect(bidding.reload.draft?).to be_falsy }
      it { expect(Notifications::Biddings::Reproved).not_to have_received(:call).with(bidding) }
    end
  end
end
