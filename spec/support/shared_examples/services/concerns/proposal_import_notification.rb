RSpec.shared_examples 'services/concerns/proposal_import_notification' do |type|
  let(:user) { create(:supplier) }
  let(:provider) { user.provider }
  let(:bidding) { create(:bidding) }
  let(:resource_name) { resource.class.to_s.underscore }
  let(:service) { described_class.new(args) }

  describe '#initialize' do
    subject { service }

    it { expect(subject.send(resource_name)).to eq resource }
    it { expect(subject.supplier).to eq user }
  end

  describe '.call' do
    subject { described_class.call(args) }

    describe 'count' do
      it { expect{ subject }.to change{ Notification.count }.by(1) }
    end

    describe 'notification' do
      let(:notification) { Notification.last }

      before { subject }

      it { expect(notification.receivable).to eq user }
      it { expect(notification.notifiable).to eq resource }
      it { expect(notification.action).to eq "proposal_import.#{type}" }
      it { expect(notification.read_at).to be_nil }

      describe 'args' do
        it { expect(notification.body_args).to eq body_args }
        it { expect(notification.extra_args).to include extra_args }
      end

      describe 'I18n' do
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
