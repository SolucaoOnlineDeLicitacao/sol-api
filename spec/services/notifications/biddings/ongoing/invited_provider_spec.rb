require 'rails_helper'

RSpec.describe Notifications::Biddings::Ongoing::InvitedProvider, type: [:service, :notification] do
  let!(:bidding)  { create(:bidding, kind: :global, status: :ongoing) }
  let(:service)   { described_class.new(bidding) }

  let!(:invite)           { create(:invite, bidding: bidding, status: :approved) }
  let!(:pending_invite)   { create(:invite, bidding: bidding, status: :pending) }
  let!(:provider)         { invite.provider }
  let!(:supplier)         { create(:supplier, provider: provider) }

  describe 'initialization' do
    it { expect(service.bidding).to eq bidding }
  end

  describe 'call' do
    let(:bidding) { create(:bidding, kind: :global, status: :ongoing) }

    describe 'count' do
      it { expect{ service.call }.to change{ Notification.count }.by(1) }
    end

    describe 'notification' do
      before { service.call }

      let!(:notification) { Notification.last }

      it { expect(notification.receivable).to eq supplier }
      it { expect(notification.notifiable).to eq bidding }
      it { expect(notification.action).to eq 'bidding.ongoing_invited_provider' }
      it { expect(notification.read_at).to be_nil }

      describe 'args' do
        it { expect(notification.body_args).to eq bidding.title }
      end
    end

    it_should_behave_like 'services/concerns/notifications/fcm'
  end
end
