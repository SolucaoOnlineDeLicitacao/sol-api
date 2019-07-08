require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to :receivable }
    it { is_expected.to belong_to :notifiable }
  end

  describe 'sortable' do
    it { expect(described_class.default_sort_column).to eq 'notifications.created_at' }
    it { expect(described_class.default_sort_direction).to eq :desc }
  end

  describe 'methods' do
    describe 'self.by_receivable' do
      let(:cooperative) { create(:cooperative) }
      let!(:user) { create(:user, cooperative: cooperative) }
      let!(:another_user) { create(:user, cooperative: cooperative) }

      let!(:notification) { create(:notification, receivable: user) }
      let!(:another_notification) { create(:notification, receivable: another_user) }

      it { expect(Notification.by_receivable(user)).to match_array [notification] }
    end
  end

  describe 'data_attrs' do
    it { is_expected.to define_data_attr(:body_args) }
    it { is_expected.to define_data_attr(:title_args) }
    it { is_expected.to define_data_attr(:extra_args) }
  end

  describe 'scopes' do
    describe '.unreads' do
      let!(:notification_read) do
        create(:notification, read_at: DateTime.current)
      end
      let!(:unread_notification) { create(:notification) }

      subject { Notification.unreads }

      it { is_expected.to eq([unread_notification]) }
    end
  end
end
