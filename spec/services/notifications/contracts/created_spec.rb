require 'rails_helper'

RSpec.describe Notifications::Contracts::Created, type: [:service, :notification] do
  include_examples 'services/concerns/init_contract'

  let(:provider) { create(:provider, type: 'Provider') }
  let!(:contract) do
    create(:contract, proposal: proposal,
                      supplier: supplier, supplier_signed_at: DateTime.current)
  end
  let(:params) { { contract: contract } }
  let(:service) { described_class.new(params) }

  describe '#initialize' do
    subject { service }

    it { expect(subject.contract).to eq contract }
  end

  describe '.call' do
    subject { described_class.call(params) }

    describe 'count' do
      it { expect{ subject }.to change{ Notification.count }.by(2) }
    end

    describe 'notification' do
      let(:notification) { Notification.where(receivable: receivable).take }

      before { subject }

      describe 'admin notification' do
        let(:receivable) { bidding.admin }

        it { expect(notification.receivable).to eq bidding.admin }
        it { expect(notification.notifiable).to eq contract }
        it { expect(notification.action).to eq 'contract.created' }
        it { expect(notification.read_at).to be_nil }

        describe 'args' do
          let(:extra_args) { { bidding_id: bidding.id }.as_json }

          it { expect(notification.extra_args).to eq extra_args }
          it { expect(notification.body_args).to eq [contract.title] }
        end

        describe 'I18n' do
          let(:title_msg) { 'Contrato criado.' }
          let(:body_msg) do
            "Novo contrato <strong>#{contract.title}</strong> gerado, "\
            "clique aqui para mais detalhes."
          end
          let(:key) { "notifications.#{notification.action}" }
          let(:title) { I18n.t("#{key}.title") % notification.title_args }
          let(:body) { I18n.t("#{key}.body") % notification.body_args }

          it { expect(title).to eq(title_msg) }
          it { expect(body).to eq(body_msg) }
        end
      end

      describe 'suppliers notification' do
        let(:receivable) { supplier }

        it { expect(notification.receivable).to eq supplier }
        it { expect(notification.notifiable).to eq contract }
        it { expect(notification.action).to eq 'contract.created' }
        it { expect(notification.read_at).to be_nil }

        describe 'args' do
          let(:extra_args) { { bidding_id: bidding.id }.as_json }

          it { expect(notification.extra_args).to eq extra_args }
          it { expect(notification.body_args).to eq [contract.title] }
        end

        describe 'I18n' do
          let(:title_msg) { 'Contrato criado.' }
          let(:body_msg) do
            "Novo contrato <strong>#{contract.title}</strong> gerado, "\
            "clique aqui para mais detalhes."
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
