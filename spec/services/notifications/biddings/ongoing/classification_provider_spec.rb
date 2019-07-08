require 'rails_helper'

RSpec.describe Notifications::Biddings::Ongoing::ClassificationProvider, type: [:service, :notification] do
  let!(:parent_classification) { create(:classification, name: 'CLASS PAI') }
  let!(:another_parent_classification) { create(:classification, name: 'CLASS PAI 2') }

  let!(:children_classification) do
    create(:classification, name: 'CLASS FILHO', classification: parent_classification)
  end

  let!(:another_children_classification) do
    create(:classification, name: 'CLASS FILHO OUTRA', classification: another_parent_classification)
  end

  let!(:bidding)  do
    create(:bidding, kind: :global, status: :ongoing, classification: parent_classification)
  end

  let(:service) { described_class.new(bidding) }

  let!(:provider) do
    prov = build(:provider, skip_classification: true)
    prov.classifications << children_classification
    prov.save

    prov
  end

  let!(:provider_without_supplier) do
    prov = build(:provider, skip_classification: true)
    prov.classifications << children_classification
    prov.save

    prov
  end

  let!(:another_provider) do
    prov = build(:provider, skip_classification: true)
    prov.classifications << another_children_classification
    prov.save

    prov
  end

  let!(:supplier) { create(:supplier, provider: provider) }
  let!(:another_supplier) { create(:supplier, provider: another_provider) }

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

      it { expect(notification.receivable).to eq supplier }
      it { expect(notification.notifiable).to eq bidding }
      it { expect(notification.action).to eq 'bidding.ongoing_classification_provider' }
      it { expect(notification.read_at).to be_nil }

      describe 'args' do
        it { expect(notification.body_args).to eq bidding.title }
      end

      describe 'I18n' do
        let(:title_msg) { "Nova licitação #{bidding.title} aberta." }
        let(:body_msg) do
         "Uma nova licitação do seu interesse (<strong>#{bidding.title}</strong>) foi aberta."
        end
        let(:key) { "notifications.#{notification.action}" }
        let(:title) { I18n.t("#{key}.title") % notification.title_args }
        let(:body) { I18n.t("#{key}.body") % notification.body_args }

        it { expect(title).to eq(title_msg) }
        it { expect(body).to eq(body_msg) }
      end

      it_should_behave_like 'services/concerns/notifications/fcm'
    end
  end
end
