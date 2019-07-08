require 'rails_helper'

RSpec.describe Notifications::Biddings::Draw::DrawProvider, type: [:service, :notification] do
  let!(:bidding)  { create(:bidding, kind: :global, status: :draw) }
  let(:service)   { described_class.new(bidding) }

  let!(:proposal) { create(:proposal, bidding: bidding, status: :draw) }
  let!(:provider) { proposal.provider }
  let!(:supplier) { create(:supplier, provider: provider) }

  let!(:proposal_2) { create(:proposal, bidding: bidding, status: :sent) }
  let!(:provider_2) { proposal_2.provider }
  let!(:supplier_2) { create(:supplier, provider: provider_2) }

  describe 'initialization' do
    it { expect(service.bidding).to eq bidding }
  end

  describe 'call' do
    let(:bidding) { create(:bidding, kind: :global, status: :draw) }

    describe 'count' do
      it { expect{ service.call }.to change{ Notification.count }.by(1) }
    end

    describe 'notification' do
      before { service.call }

      let!(:notification) { Notification.last }

      it { expect(notification.receivable).to eq supplier }
      it { expect(notification.notifiable).to eq bidding }
      it { expect(notification.action).to eq 'bidding.draw_draw_provider' }
      it { expect(notification.read_at).to be_nil }

      describe 'args' do
        it { expect(notification.body_args).to eq [bidding.title, I18n.l(bidding.draw_at)] }
      end
    end

    it_should_behave_like 'services/concerns/notifications/fcm'
  end
end
