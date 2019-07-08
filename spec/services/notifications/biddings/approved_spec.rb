require 'rails_helper'

RSpec.describe Notifications::Biddings::Approved, type: [:service, :notification] do
  let!(:bidding) { create(:bidding, kind: :global, status: :approved) }
  let(:service) { described_class.new(bidding) }

  let(:covenant) { bidding.covenant }
  let(:cooperative) { covenant.cooperative }
  let!(:user) { create(:user, cooperative: cooperative) }

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

      it { expect(notification.receivable).to eq user }
      it { expect(notification.notifiable).to eq bidding }
      it { expect(notification.action).to eq 'bidding.approved' }
      it { expect(notification.read_at).to be_nil }

      describe 'args' do
        it { expect(notification.body_args).to eq [bidding.title, I18n.l(bidding.start_date)] }
      end
    end

    it_should_behave_like 'services/concerns/notifications/fcm'
  end
end
