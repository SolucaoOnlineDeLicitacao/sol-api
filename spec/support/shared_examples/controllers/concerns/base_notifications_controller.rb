RSpec.shared_examples "controllers/concerns/base_notifications_controller" do
  let(:serializer) { NotificationSerializer }
  let!(:notification_read) do
    create(:notification, receivable: user, read_at: DateTime.current)
  end
  let!(:unread_notification) { create(:notification, receivable: user) }
  let(:notifications) { [unread_notification, notification_read] }
  let(:notification) { notifications.first }

  before { oauth_token_sign_in user }

  describe '#index' do
    let(:params) { {} }

    subject(:get_index) { get :index, params: params, xhr: true }

    describe 'helpers' do
      let!(:params) do
        { search: 'search', page: 2, sort_column: 'created_at', sort_direction: 'desc' }
      end

      let(:exposed_notifications) { Notification.all }

      before do
        allow(exposed_notifications).to receive(:sorted) { exposed_notifications }
        allow(exposed_notifications).to receive(:page).with(anything()).and_call_original
        allow(controller).to receive(:notifications) { exposed_notifications }

        get_index
      end

      it { expect(exposed_notifications).to have_received(:sorted).with('created_at', 'desc') }
      it { expect(exposed_notifications).to have_received(:page).at_least(:once).with(2) }
      it { expect(described_class::PER_PAGE).to eq 20 }
    end

    describe 'response' do
      let!(:another_notification) { create(:notification) }

      before { get_index }

      describe 'http_status' do
        it { expect(response).to have_http_status :ok }
      end

      describe 'exposes' do
        it { expect(controller.notifications).to match_array notifications }
      end

      describe 'JSON' do
        let(:json) { JSON.parse(response.body) }
        let(:expected_json) { notifications.map { |notification| format_json(serializer, notification) } }

        it { expect(json).to match_array expected_json }
      end
    end

    describe 'unreads' do
      let(:params) { { unreads: true } }

      before { get_index }

      it { expect(controller.notifications).to eq([unread_notification]) }
    end
  end

  describe '#mark_as_read' do
    let(:params) { { id: notification } }

    subject(:patch_mark_as_read) { patch :mark_as_read, params: params, xhr: true }

    before { patch_mark_as_read }

    describe 'http_status' do
      it { expect(response).to have_http_status :ok }
    end

    describe 'exposes' do
      it { expect(controller.notification).to eq notification }
    end

    describe 'updates_read_at' do
      before do
        notification.read_at = datetime
        notification.save

        patch_mark_as_read

        notification.reload
      end

      context 'when not read' do
        let!(:datetime) { nil }

        it { expect(notification.read_at).to be_within(1.second).of(DateTime.current) }
      end

      context 'when read' do
        let!(:datetime) { DateTime.new(2019, 1, 1) }

        it { expect(notification.read_at).to eq DateTime.new(2019, 1, 1) }
      end
    end
  end


end
