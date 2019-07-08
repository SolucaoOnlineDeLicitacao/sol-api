require 'rails_helper'

RSpec.describe Bidding::Minute::AddendumPdfGenerateWorker, type: :worker do
  let(:contract) { create(:contract) }
  let(:service) { BiddingsService::Minute::AddendumPdfGenerate }
  let(:service_method) { :call! }
  let(:params) { [contract.id] }

  include_examples 'workers/perform_with_params'
end
