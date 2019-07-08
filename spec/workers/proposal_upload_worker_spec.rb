require 'rails_helper'

RSpec.describe ProposalUploadWorker, type: :worker do
  describe '#perform' do
    let(:import) do
      create(:proposal_import, bidding: bidding, provider: provider)
    end
    let(:notification_class) { 'Notifications::ProposalImports' }
    let(:notification_type) { nil }

    context 'when have sidekiq options' do
      it { is_expected.to be_processed_in :default }
      it { is_expected.to be_retryable 5 }
    end

    include_examples 'workers/perform_upload_job'
  end
end
