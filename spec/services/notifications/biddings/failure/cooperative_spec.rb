require 'rails_helper'

RSpec.describe Notifications::Biddings::Failure::Cooperative, type: [:service, :notification] do
  let!(:bidding)    { create(:bidding, kind: :global, status: :failure) }
  let(:service)     { described_class.new(bidding) }

  let(:covenant)    { bidding.covenant }
  let(:cooperative) { covenant.cooperative }
  let!(:user)       { create(:user, cooperative: cooperative) }

  describe 'initialization' do
    it { expect(service.bidding).to eq bidding }
  end

  describe 'call' do
    describe 'count' do
      it { expect{ service.call }.to change{ Notification.count }.by(1) }
    end

    describe 'notification' do
      before { service.call }

      let!(:notification) { Notification.last }

      it { expect(notification.receivable).to eq cooperative.users.first }
      it { expect(notification.notifiable).to eq bidding }
      it { expect(notification.action).to eq 'bidding.failure_cooperative' }
      it { expect(notification.read_at).to be_nil }

      describe 'args' do
        it { expect(notification.body_args).to eq [bidding.title, nil] }
      end
    end

    describe 'with comment' do
      let!(:failure) do
        create(:event_bidding_failure, from: 'waiting', to: 'failure',
          eventable: bidding, comment: 'Oh noes')
      end
      let(:notification) { Notification.last }

      before { service.call }

      describe 'args' do
        it { expect(notification.body_args).to eq [bidding.title, failure.comment] }
      end
    end

    describe 'I18n' do
      describe 'without comment' do
        let(:notification) { Notification.last }
        let(:title_msg) { "Licitação #{bidding.title} fracassada." }
        let(:body_msg) do
          "O revisor fracassou a licitação <strong>#{bidding.title}</strong>, motivo: <strong></strong>"
        end
        let(:key) { "notifications.#{notification.action}" }
        let(:title) { I18n.t("#{key}.title") % notification.title_args }
        let(:body) { I18n.t("#{key}.body") % notification.body_args }

        before { service.call }

        it { expect(title).to eq(title_msg) }
        it { expect(body).to eq(body_msg) }
      end

      describe 'with comment' do
        let!(:failure) do
          create(:event_bidding_failure, from: 'waiting', to: 'failure',
            eventable: bidding, comment: 'Oh noes')
        end
        let(:notification) { Notification.last }
        let(:title_msg) { "Licitação #{bidding.title} fracassada." }
        let(:body_msg) do
          "O revisor fracassou a licitação <strong>#{bidding.title}</strong>, motivo: <strong>#{failure.comment}</strong>"
        end
        let(:key) { "notifications.#{notification.action}" }
        let(:title) { I18n.t("#{key}.title") % notification.title_args }
        let(:body) { I18n.t("#{key}.body") % notification.body_args }

        before { service.call }

        it { expect(title).to eq(title_msg) }
        it { expect(body).to eq(body_msg) }
      end
    end

    it_should_behave_like 'services/concerns/notifications/fcm'
  end
end
