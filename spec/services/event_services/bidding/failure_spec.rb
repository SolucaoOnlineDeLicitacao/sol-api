require 'rails_helper'

RSpec.describe EventServices::Bidding::Failure, type: :service do

  let(:user) { create(:admin) }
  let(:bidding) { create(:bidding) }
  let(:comment) { 'a comment' }
  let(:params) do
    {
      bidding: bidding,
      comment: comment,
      creator: user
    }
  end

  subject(:service) do
    described_class.new(params)
  end

  describe '#initializer' do
    it { expect(service.bidding).to eq bidding }
    it { expect(service.comment).to eq comment }
    it { expect(service.creator).to eq user }
  end

  describe '.call' do
    context 'when return success' do
      before { service.call }

      it { expect(service.event).to be_persisted }
    end

    context 'when failure' do
      let(:error_event_key) { [:comment] }
      before do
        params.delete(:comment)
        service.call
      end

      it { expect(service.event).not_to be_persisted }
      it { expect(service.event.errors.messages.keys).to eq error_event_key }
    end
  end
end
