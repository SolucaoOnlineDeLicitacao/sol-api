require 'rails_helper'

 RSpec.describe Notifications::Biddings::Additives::Created, type: [:service, :notification] do
  let!(:bidding)  { create(:bidding, kind: :global, status: :ongoing) }
  let(:service)   { described_class.new(bidding) }

   let(:cooperative) { bidding.cooperative }
  let!(:proposal)   { create(:proposal, bidding: bidding) }
  let!(:provider)   { proposal.provider }
  let!(:admin)      { bidding.admin }
  let!(:supplier)   { create(:supplier, provider: provider) }
  let!(:user)       { create(:user, cooperative: cooperative) }
  let(:invite)      { create(:invite, bidding: bidding) }
  let(:invited_provider)  { invite.provider }
  let!(:invited_supplier) { create(:supplier, provider: invited_provider) }

   describe '#initialize' do
    it { expect(service.bidding).to eq bidding }
  end

   describe '.call' do
    let(:bidding) { create(:bidding, kind: :global, status: :ongoing) }

     describe 'count' do
      it { expect{ service.call }.to change{ Notification.count }.by(4) }
    end

     describe 'notifications' do
      before { service.call }

       describe 'I18n' do
        # same notification for all users so we wont need to check locale 4 times
        let(:notification) { Notification.last }

         let(:title_msg) { "Alteração na data de encerramento da licitação #{bidding.title}." }
        let(:key)       { "notifications.#{notification.action}" }
        let(:title)     { I18n.t("#{key}.title") % notification.title_args }
        let(:body)      { I18n.t("#{key}.body") % notification.body_args }
        let(:body_msg) do
          "Um aditivo foi criado para a licitação <strong>#{bidding.title}</strong>. A nova data de encerramento é <strong>#{I18n.l(bidding.closing_date)}</strong>."
        end

         it { expect(title).to eq(title_msg) }
        it { expect(body).to eq(body_msg) }
      end


       describe 'admin notification' do
        let!(:notification) { admin.notifications.last }

         it { expect(notification.notifiable).to eq bidding }
        it { expect(notification.action).to eq 'bidding.additive_created' }
        it { expect(notification.read_at).to be_nil }

         describe 'args' do
          it { expect(notification.body_args).to eq [bidding.title, I18n.l(bidding.closing_date)] }
        end
      end

       describe 'suppliers notification' do
        describe 'proposal supplier' do
          let!(:notification) { supplier.notifications.last }

           it { expect(notification.notifiable).to eq bidding }
          it { expect(notification.action).to eq 'bidding.additive_created' }
          it { expect(notification.read_at).to be_nil }

           describe 'args' do
            it { expect(notification.body_args).to eq [bidding.title, I18n.l(bidding.closing_date)] }
          end
        end

         describe 'invited supplier' do
          let!(:notification) { invited_supplier.notifications.last }

           it { expect(notification.receivable).to eq invited_supplier }
          it { expect(notification.notifiable).to eq bidding }
          it { expect(notification.action).to eq 'bidding.additive_created' }
          it { expect(notification.read_at).to be_nil }

           describe 'args' do
            it { expect(notification.body_args).to eq [bidding.title, I18n.l(bidding.closing_date)] }
          end
        end
      end

       describe 'user notification' do
        let!(:notification) { user.notifications.last }

         it { expect(notification.receivable).to eq user }
        it { expect(notification.notifiable).to eq bidding }
        it { expect(notification.action).to eq 'bidding.additive_created' }
        it { expect(notification.read_at).to be_nil }

         describe 'args' do
          it { expect(notification.body_args).to eq [bidding.title, I18n.l(bidding.closing_date)] }
        end
      end
    end

     it_should_behave_like 'services/concerns/notifications/fcm', 4
  end
end
