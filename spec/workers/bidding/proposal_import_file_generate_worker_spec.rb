require 'rails_helper'

RSpec.describe Bidding::ProposalImportFileGenerateWorker, type: :worker do
  let(:bidding) { create(:bidding) }
  let(:service) { BiddingsService::ProposalImports::Download }
  let(:service_method) { :call }
  let(:params) { [bidding.id] }

  include_examples 'workers/perform_with_params'
end
