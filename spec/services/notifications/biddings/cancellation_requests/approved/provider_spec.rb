require 'rails_helper'

RSpec.describe Notifications::Biddings::CancellationRequests::Approved::Provider, type: [:service, :notification] do
  let!(:bidding)    { create(:bidding, kind: :global, status: :approved) }
  let(:service)     { described_class.new(bidding) }

  let!(:proposal) { create(:proposal, bidding: bidding) }
  let!(:provider) { proposal.provider }
  let!(:supplier) { create(:supplier, provider: provider) }

  let!(:event_bidding_cancellation_request) do
    create(:event_bidding_cancellation_request, from: 'draft', to: 'canceled',
      eventable: bidding, comment: 'Oh noes', comment_response: 'Oh yeah',
      status: 'approved')
  end

  let!(:event) do
    bidding.event_cancellation_requests&.changing_to('canceled')&.last
  end

  describe 'initialization' do
    it { expect(service.bidding).to eq bidding }
  end

  describe 'call' do
    let(:bidding) { create(:bidding, kind: :global, status: :approved) }

    describe 'count' do
      it { expect{ service.call }.to change{ Notification.count }.by(1) }
    end

    describe 'notification' do
      before { service.call }

      let!(:notification) { Notification.last }

      it { expect(notification.receivable).to eq supplier }
      it { expect(notification.notifiable).to eq bidding }
      it { expect(notification.action).to eq 'bidding.cancellation_request_approved_provider' }
      it { expect(notification.read_at).to be_nil }

      describe 'args' do
        it { expect(notification.body_args).to eq [bidding.title, event.comment_response] }
      end
    end

    it_should_behave_like 'services/concerns/notifications/fcm'
  end
end
