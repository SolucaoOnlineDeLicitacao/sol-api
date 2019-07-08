require 'rails_helper'

RSpec.describe NotificationSerializer, type: :serializer do
  let(:object) { create(:notification, read_at: DateTime.now) }

  subject { format_json(described_class, object) }

  describe 'attributes' do
    let(:title) { I18n.t("notifications.#{object.action}.title") % object.title_args }
    let(:body) { I18n.t("notifications.#{object.action}.body") % object.body_args }

    it { is_expected.to include 'id' => object.id }
    it { is_expected.to include 'action' => object.action }
    it { is_expected.to include 'read_at' => object.read_at.rfc2822 }
    it { is_expected.to include 'created_at' => object.created_at.rfc2822 }
    it { is_expected.to include 'title' => title }
    it { is_expected.to include 'body' => body }
    it { is_expected.to include 'notifiable_id' => object.notifiable_id }
    it { is_expected.to include 'args' => object.extra_args }
  end
end
