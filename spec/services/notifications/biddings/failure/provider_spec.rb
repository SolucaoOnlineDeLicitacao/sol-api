require 'rails_helper'

RSpec.describe Notifications::Biddings::Failure::Provider, type: [:service, :notification] do
  let!(:bidding) { create(:bidding, kind: :global, status: :failure) }
  let(:service)   { described_class.new(bidding) }

  let!(:proposal) { create(:proposal, bidding: bidding) }
  let!(:provider) { proposal.provider }
  let!(:supplier) { create(:supplier, provider: provider) }

  describe 'initialization' do
    it { expect(service.bidding).to eq bidding }
  end

  describe 'call' do
    let(:bidding) { create(:bidding, kind: :global, status: :failure) }

    describe 'count' do
      it { expect{ service.call }.to change{ Notification.count }.by(1) }
    end

    describe 'notification' do
      before { service.call }

      let!(:notification) { Notification.last }

      it { expect(notification.receivable).to eq supplier }
      it { expect(notification.notifiable).to eq bidding }
      it { expect(notification.action).to eq 'bidding.failure_provider' }
      it { expect(notification.read_at).to be_nil }

      describe 'args' do
        it { expect(notification.body_args).to eq bidding.title }
      end
    end

    it_should_behave_like 'services/concerns/notifications/fcm'
  end
end
