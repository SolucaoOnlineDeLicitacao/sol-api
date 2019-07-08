require 'rails_helper'

RSpec.describe Notifications::Biddings::UnderReview::Provider, type: [:service, :notification] do
  let!(:bidding)  { create(:bidding, kind: :global, status: :under_review) }
  let(:service)   { described_class.new(bidding) }
  let(:cooperative) { bidding.cooperative }
  let!(:proposal) { create(:proposal, bidding: bidding) }
  let!(:provider) { proposal.provider }
  let!(:supplier) { create(:supplier, provider: provider) }
  let(:invite)      { create(:invite, bidding: bidding) }
  let(:invited_provider)  { invite.provider }
  let!(:invited_supplier) { create(:supplier, provider: invited_provider) }

  describe 'initialization' do
    it { expect(service.bidding).to eq bidding }
  end

  describe 'call' do
    let(:bidding) { create(:bidding, kind: :global, status: :under_review) }

    describe 'count' do
      it { expect{ service.call }.to change{ Notification.count }.by(2) }
    end

    describe 'notifications' do
      before { service.call }

      describe 'I18n' do
        let(:notification) { Notification.last }

        let(:title_msg) { "Licitação #{bidding.title} em análise." }
        let(:key)       { "notifications.#{notification.action}" }
        let(:title)     { I18n.t("#{key}.title") % notification.title_args }
        let(:body)      { I18n.t("#{key}.body") % notification.body_args }
        let(:body_msg) do
          "A licitação <strong>#{bidding.title}</strong> está em análise. Aguarde a análise das propostas pela associação <strong>#{cooperative.name}</strong>."
        end

        it { expect(title).to eq(title_msg) }
        it { expect(body).to eq(body_msg) }
      end

      describe 'proposal supplier' do
        let!(:notification) { supplier.notifications.last }

        it { expect(notification.notifiable).to eq bidding }
        it { expect(notification.action).to eq 'bidding.under_review_provider' }
        it { expect(notification.read_at).to be_nil }

        describe 'args' do
          it { expect(notification.body_args).to eq [bidding.title, cooperative.name] }
        end
      end

      describe 'invited supplier' do
        let!(:notification) { invited_supplier.notifications.last }

        it { expect(notification.receivable).to eq invited_supplier }
        it { expect(notification.notifiable).to eq bidding }
        it { expect(notification.action).to eq 'bidding.under_review_provider' }
        it { expect(notification.read_at).to be_nil }

        describe 'args' do
          it { expect(notification.body_args).to eq [bidding.title, cooperative.name] }
        end
      end
    end

    it_should_behave_like 'services/concerns/notifications/fcm', 2
  end
end
