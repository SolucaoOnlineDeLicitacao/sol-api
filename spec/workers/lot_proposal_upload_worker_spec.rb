require 'rails_helper'

RSpec.describe LotProposalUploadWorker, type: :worker do
  describe '#perform' do
    let(:import) do
      create(:lot_proposal_import, bidding: bidding, provider: provider)
    end
    let(:notification_class) { 'Notifications::ProposalImports::Lots' }
    let(:notification_type) { 'lot_' }

    context 'when have sidekiq options' do
      it { is_expected.to be_processed_in :default }
      it { is_expected.to be_retryable 5 }
    end

    include_examples 'workers/perform_upload_job'
  end
end
