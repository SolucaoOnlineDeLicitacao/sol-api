require 'rails_helper'

RSpec.describe Notifications::Biddings::CancellationRequests::New, type: :service do
  let!(:bidding)  { create(:bidding, kind: :global, status: :waiting) }
  let(:service)   { described_class.new(bidding) }

  let(:covenant)  { bidding.covenant }
  let(:admin)     { covenant.admin }

  describe 'initialization' do
    it { expect(service.bidding).to eq bidding }
  end

  describe 'call' do
    let(:bidding) { create(:bidding, kind: :global, status: :waiting) }

    describe 'count' do
      it { expect{ service.call }.to change{ Notification.count }.by(1) }
    end

    describe 'notification' do
      before { service.call }

      let!(:notification) { Notification.last }

      it { expect(notification.receivable).to eq admin }
      it { expect(notification.notifiable).to eq bidding }
      it { expect(notification.action).to eq 'bidding.cancellation_request_new' }
      it { expect(notification.read_at).to be_nil }

      describe 'args' do
        it { expect(notification.body_args).to eq bidding.title }
      end
    end

    it_should_behave_like 'services/concerns/notifications/fcm'
  end
end
