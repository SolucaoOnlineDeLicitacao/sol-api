require 'rails_helper'

RSpec.describe Notifications::Proposals::Accepted, type: [:service, :notification] do
  let!(:bidding)    { create(:bidding, kind: :global, status: :approved) }
  let!(:proposal)   { create(:proposal, bidding: bidding, status: :coop_accepted) }
  let(:service)     { described_class.new(proposal) }

  let!(:lot)        { bidding.lots.first }
  let(:covenant)    { bidding.covenant }
  let(:cooperative) { covenant.cooperative }
  let!(:user)       { create(:user, cooperative: cooperative) }
  let!(:provider)   { proposal.provider }

  describe 'initialization' do
    it { expect(service.proposal).to eq proposal }
    it { expect(service.bidding).to eq bidding }
  end

  describe 'call' do
    describe 'count' do
      it { expect{ service.call }.to change{ Notification.count }.by(1) }
    end

    describe 'notification' do
      before { service.call }

      let!(:notification) { Notification.last }

      it { expect(notification.receivable).to eq user }
      it { expect(notification.notifiable).to eq proposal }
      it { expect(notification.action).to eq 'proposal.accepted' }
      it { expect(notification.read_at).to be_nil }

      describe 'args' do
        let(:extra_args) { { bidding_id: bidding.id }.as_json }

        it { expect(notification.body_args).to eq [provider.name, bidding.title] }
        it { expect(notification.extra_args).to eq extra_args }
      end
    end

    it_should_behave_like 'services/concerns/notifications/fcm'
  end
end
