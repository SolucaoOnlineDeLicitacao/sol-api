require 'rails_helper'

RSpec.describe Notifications::Biddings::Failure::All::Cooperative, type: [:service, :notification] do
  let!(:bidding) { create(:bidding, kind: :global, status: :failure) }
  let(:params) { bidding }

  let(:covenant)    { bidding.covenant }
  let(:cooperative) { covenant.cooperative }
  let!(:user)       { create(:user, cooperative: cooperative) }
  let(:service)     { described_class.new(params) }

  describe '#initialize' do
    subject { service }

    it { expect(subject.bidding).to eq bidding }
  end

  describe '.call' do
    subject { described_class.call(params) }

    describe 'count' do
      it { expect{ subject }.to change{ Notification.count }.by(1) }
    end

    describe 'notification' do
      context 'without comment' do
        let(:notification) { Notification.last }

        before { subject }

        it { expect(notification.receivable).to eq cooperative.users.first }
        it { expect(notification.notifiable).to eq bidding }
        it { expect(notification.action).to eq 'bidding.failure_all_cooperative' }
        it { expect(notification.read_at).to be_nil }

        describe 'args' do
          it { expect(notification.body_args).to eq bidding.title }
        end

        describe 'I18n' do
          let(:notification) { Notification.last }
          let(:title_msg) { "Licitação #{bidding.title} fracassada." }
          let(:body_msg) do
            "A licitação <strong>#{bidding.title}</strong> sem proposta vencedora, foi fracassada"
          end
          let(:key) { "notifications.#{notification.action}" }
          let(:title) { I18n.t("#{key}.title") % notification.title_args }
          let(:body) { I18n.t("#{key}.body") % notification.body_args }

          before { subject }

          it { expect(title).to eq(title_msg) }
          it { expect(body).to eq(body_msg) }
        end
      end
    end

    it_should_behave_like 'services/concerns/notifications/fcm'
  end
end
