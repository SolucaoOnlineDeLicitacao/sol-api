require 'rails_helper'

RSpec.describe Bidding::Minute::AddendumAcceptedPdfGenerateWorker, type: :worker do
  let(:contract) { create(:contract, deleted_at: Date.current) }
  let(:bidding) { create(:bidding, reopen_reason_contract: contract) }
  let(:service) { BiddingsService::Minute::AddendumAcceptedPdfGenerate }
  let(:service_method) { :call! }
  let(:params) { [bidding.id] }

  include_examples 'workers/perform_with_params'
end
