RSpec.shared_examples 'services/concerns/notifications/fcm' do |times|
  let(:time) { times || 1 }

  describe 'fcm' do
    let(:notification) { create(:notification) }
    let(:fcm_response) { double('call', call: true) }

    before do
      allow(::Notifications::Fcm).to receive(:delay).and_return(fcm_response)
      allow(Notification).to receive(:create).and_return(notification_response)

      service.call
    end

    context 'when created notification' do
      let(:notification_response) { notification }

      it { expect(::Notifications::Fcm).to have_received(:delay).exactly(time).times }
    end

    context 'when not created notification' do
      let(:notification_response) { nil }

      it { expect(::Notifications::Fcm).not_to have_received(:delay) }
    end
  end
end
