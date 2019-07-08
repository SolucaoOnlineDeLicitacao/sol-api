require 'rails_helper'

RSpec.describe Bidding::LotProposalImportFileGenerateWorker, type: :worker do
  let(:bidding) { create(:bidding) }
  let(:lot) { bidding.lots.first }
  let(:service) { BiddingsService::LotProposalImports::Download }
  let(:service_method) { :call }
  let(:params) { [bidding.id, lot.id] }

  include_examples 'workers/perform_with_params'
end
