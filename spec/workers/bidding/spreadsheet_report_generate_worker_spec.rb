require 'rails_helper'

RSpec.describe Bidding::SpreadsheetReportGenerateWorker, type: :worker do
  let(:bidding) { create(:bidding) }
  let(:service) { BiddingsService::SpreadsheetReportGenerate }
  let(:service_method) { :call! }
  let(:params) { [bidding.id] }

  include_examples 'workers/perform_with_params'
end
