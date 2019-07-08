RSpec.shared_examples 'workers/perform_without_params' do
  describe '#perform' do
    context 'when have sidekiq options' do
      it { is_expected.to be_processed_in :default }
      it { is_expected.to be_retryable 5 }
    end

    context 'when the job is enqueued' do
      before { described_class.perform_async }

      it { expect(described_class).to have_enqueued_sidekiq_job }
    end

    context 'when the job is running' do
      before do
        allow(service).to receive(service_method).and_return(true)

        described_class.perform_async
        described_class.drain
      end

      it { expect(service).to have_received(service_method) }
    end
  end
end
