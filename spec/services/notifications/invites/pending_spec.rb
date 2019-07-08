require 'rails_helper'

RSpec.describe Notifications::Invites::Pending, type: [:service, :notification] do
  let!(:bidding)    { create(:bidding, kind: :global, status: :approved) }
  let!(:invite)     { create(:invite, bidding: bidding, status: :pending) }
  let(:service)     { described_class.new(invite) }

  let(:covenant)    { bidding.covenant }
  let(:cooperative) { covenant.cooperative }
  let!(:provider)   { invite.provider }
  let!(:user)       { create(:user, cooperative: cooperative) }

  describe 'initialization' do
    it { expect(service.invite).to eq invite }
    it { expect(service.bidding).to eq bidding }
    it { expect(service.provider).to eq provider }
  end

  describe 'call' do
    describe 'count' do
      it { expect{ service.call }.to change{ Notification.count }.by(1) }
    end

    describe 'notification' do
      before { service.call }

      let!(:notification) { Notification.last }

      it { expect(notification.receivable).to eq user }
      it { expect(notification.notifiable).to eq invite }
      it { expect(notification.action).to eq 'invite.pending' }
      it { expect(notification.read_at).to be_nil }

      describe 'args' do
        let(:extra_args) { { bidding_id: bidding.id }.as_json }

        it { expect(notification.extra_args).to eq extra_args }
        it { expect(notification.body_args).to eq [provider.name, bidding.title] }
      end
    end

    it_should_behave_like 'services/concerns/notifications/fcm'
  end
end
