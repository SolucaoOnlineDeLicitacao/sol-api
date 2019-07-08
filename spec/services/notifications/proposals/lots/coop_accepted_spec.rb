require 'rails_helper'

RSpec.describe Notifications::Proposals::Lots::CoopAccepted, type: [:service, :notification] do
  let!(:bidding)    { create(:bidding, kind: :global, status: :approved) }
  let!(:lot)        { bidding.lots.first }
  let!(:proposal)   { create(:proposal, bidding: bidding) }
  let(:service)     { described_class.new(proposal, lot) }

  let!(:lot)        { bidding.lots.first }
  let(:covenant)    { bidding.covenant }
  let(:admin)       { covenant.admin }

  describe 'initialization' do
    it { expect(service.proposal).to eq proposal }
  end

  describe 'call' do
    describe 'count' do
      it { expect{ service.call }.to change{ Notification.count }.by(1) }
    end

    describe 'notification' do
      before { service.call }

      let!(:notification) { Notification.last }

      it { expect(notification.receivable).to eq admin }
      it { expect(notification.notifiable).to eq proposal }
      it { expect(notification.action).to eq 'proposal.lot_coop_accepted' }
      it { expect(notification.read_at).to be_nil }

      describe 'args' do
        let(:extra_args) do
          { bidding_id: bidding.id, lot_id: lot.id, covenant_id: bidding.covenant_id }.as_json
        end

        it { expect(notification.body_args).to eq [lot.name, bidding.title] }
        it { expect(notification.extra_args).to eq extra_args }
      end
    end

    it_should_behave_like 'services/concerns/notifications/fcm'
  end
end
