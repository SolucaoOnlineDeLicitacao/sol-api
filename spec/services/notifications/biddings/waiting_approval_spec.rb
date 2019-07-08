require 'rails_helper'

RSpec.describe Notifications::Biddings::WaitingApproval, type: [:service, :notification] do
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
      it { expect(notification.action).to eq 'bidding.waiting_approval' }
      it { expect(notification.read_at).to be_nil }

      describe 'args' do
        it { expect(notification.body_args).to eq bidding.title }
      end

      describe 'I18n' do
        let(:title_msg) { "Licitação #{bidding.title} aguardando liberação." }
        let(:body_msg) do
          "A licitação <strong>#{bidding.title}</strong> foi criada e aguarda liberação."
        end
        let(:key) { "notifications.#{notification.action}" }
        let(:title) { I18n.t("#{key}.title") % notification.title_args }
        let(:body) { I18n.t("#{key}.body") % notification.body_args }

        it { expect(title).to eq(title_msg) }
        it { expect(body).to eq(body_msg) }
      end
    end

    it_should_behave_like 'services/concerns/notifications/fcm'
  end
end
