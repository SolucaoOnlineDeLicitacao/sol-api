RSpec.shared_examples 'workers/perform_upload_job' do
  let(:user) { create(:supplier) }
  let(:provider) { user.provider }
  let(:bidding) { create(:bidding) }

  context 'when the job is enqueued' do
    before { described_class.perform_async(user.id, import.id) }

    it do
      expect(described_class).
        to have_enqueued_sidekiq_job(user.id, import.id)
    end
  end

  context 'when the job is running' do
    let(:upload_service_params) do
      {
        user_id: user.id,
        import_model: import.class,
        import_id: import.id,
        notification_class: notification_class,
        notification_type: notification_type
      }
    end

    before do
      allow(BiddingsService::Upload).
        to receive(:call).with(upload_service_params).and_return(true)

      described_class.perform_async(user.id, import.id)
      described_class.drain
    end

    it do
      expect(BiddingsService::Upload).
        to have_received(:call).with(upload_service_params)
    end
  end
end
