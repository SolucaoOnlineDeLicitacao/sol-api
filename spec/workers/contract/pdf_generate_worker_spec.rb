require 'rails_helper'

RSpec.describe Contract::PdfGenerateWorker, type: :worker do
  let(:contract) { create(:contract) }
  let(:service) { ContractsService::PdfGenerate }
  let(:service_method) { :call! }
  let(:params) { [contract.id] }

  include_examples 'workers/perform_with_params'
end
