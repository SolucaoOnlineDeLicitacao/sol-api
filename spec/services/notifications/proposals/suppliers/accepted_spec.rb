require 'rails_helper'

RSpec.describe Notifications::Proposals::Suppliers::Accepted, type: [:service, :notification] do
  let!(:bidding) { create(:bidding, kind: :global, status: :finnished) }
  let!(:accepted_proposal) { create(:proposal, bidding: bidding, status: :accepted) }
  let!(:coop_accepted_proposal) { create(:proposal, bidding: bidding, status: :coop_accepted) }
  let(:service) { described_class.new(accepted_proposal) }

  let!(:lot)        { bidding.lots.first }
  let(:covenant)    { bidding.covenant }
  let(:cooperative) { covenant.cooperative }
  let!(:user)       { create(:user, cooperative: cooperative) }
  let!(:provider)   { accepted_proposal.provider }
  let!(:suppliers)  { create_list(:supplier, 2, provider: provider) }

  describe 'initialization' do
    it { expect(service.proposal).to eq accepted_proposal }
  end

  describe '.call' do
    describe 'count' do
      it { expect{ service.call }.to change{ Notification.count }.by(2) }
    end

    describe 'notification' do
      let(:notification) { Notification.where(receivable: receivable).take }
      let(:lots_name) { accepted_proposal.lot_proposals.map(&:lot).map(&:name).to_sentence }

      before { service.call }

      context 'when send to last supplier' do
        let(:receivable) { suppliers.last }

        it { expect(notification.receivable).to eq suppliers.last }
        it { expect(notification.notifiable).to eq accepted_proposal }
        it { expect(notification.action).to eq 'proposal.supplier_accepted' }
        it { expect(notification.read_at).to be_nil }

        describe 'args' do
          let(:extra_args) { { bidding_id: bidding.id }.as_json }

          it { expect(notification.body_args).to eq [lots_name] }
          it { expect(notification.extra_args).to eq extra_args }
        end

        describe 'I18n' do
          let(:title_msg) { 'Parabéns, você foi o vencedor.' }
          let(:body_msg) do
            "Parabéns, você foi o vencedor do(s) <strong>#{lots_name}</strong>, clique aqui para detalhes"
          end
          let(:key) { "notifications.#{notification.action}" }
          let(:title) { I18n.t("#{key}.title") % notification.title_args }
          let(:body) { I18n.t("#{key}.body") % notification.body_args }

          it { expect(title).to eq(title_msg) }
          it { expect(body).to eq(body_msg) }
        end
      end

      context 'when send to first supplier' do
        let(:receivable) { suppliers.first }

        it { expect(notification.receivable).to eq suppliers.first }
        it { expect(notification.notifiable).to eq accepted_proposal }
        it { expect(notification.action).to eq 'proposal.supplier_accepted' }
        it { expect(notification.read_at).to be_nil }

        describe 'args' do
          let(:extra_args) { { bidding_id: bidding.id }.as_json }

          it { expect(notification.body_args).to eq [lots_name] }
          it { expect(notification.extra_args).to eq extra_args }
        end

        describe 'I18n' do
          let(:title_msg) { 'Parabéns, você foi o vencedor.' }
          let(:body_msg) do
            "Parabéns, você foi o vencedor do(s) <strong>#{lots_name}</strong>, clique aqui para detalhes"
          end
          let(:key) { "notifications.#{notification.action}" }
          let(:title) { I18n.t("#{key}.title") % notification.title_args }
          let(:body) { I18n.t("#{key}.body") % notification.body_args }

          it { expect(title).to eq(title_msg) }
          it { expect(body).to eq(body_msg) }
        end
      end
    end

    it_should_behave_like 'services/concerns/notifications/fcm', 2
  end
end
