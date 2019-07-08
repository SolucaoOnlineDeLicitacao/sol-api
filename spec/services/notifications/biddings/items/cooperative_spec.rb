require 'rails_helper'

RSpec.describe Notifications::Biddings::Items::Cooperative, type: [:service, :notification] do
  let(:item) { create(:item) }
  let(:group_item) { create(:group_item, item: item) }
  let(:lot_group_item) { create(:lot_group_item, group_item: group_item) }
  let(:lot) do
    create(:lot, build_lot_group_item: false, lot_group_items: [lot_group_item])
  end
  let(:bidding) do
    create(:bidding, build_lot: false, lots: [lot], status: :draft)
  end
  let(:covenant) { bidding.covenant }
  let(:cooperative) { covenant.cooperative }
  let!(:user) { create(:user, cooperative: cooperative) }
  let(:params) { [bidding, item] }
  let(:service) { described_class.new(*params) }

  describe '#initialize' do
    subject { described_class.new(*params) }

    it { expect(subject.bidding).to eq bidding }
    it { expect(subject.item).to eq item }
  end

  describe '.call' do
    subject { described_class.call(*params) }

    describe 'count' do
      it { expect{ subject }.to change{ Notification.count }.by(1) }
    end

    describe 'notification' do
      before { subject }

      let(:notification) { Notification.last }

      it { expect(notification.receivable).to eq cooperative.users.first }
      it { expect(notification.notifiable).to eq bidding }
      it { expect(notification.action).to eq 'bidding.item_cooperative' }
      it { expect(notification.read_at).to be_nil }

      describe 'args' do
        it { expect(notification.body_args).to eq [bidding.title, item.title] }
        it { expect(notification.extra_args).to be_nil }
      end

      describe 'I18n' do
        let(:title_msg) { "Licitação #{bidding.title} com item alterado." }
        let(:body_msg) do
          "A licitação <strong>#{bidding.title}</strong> teve o item <strong>#{item.title}</strong> alterado."
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
