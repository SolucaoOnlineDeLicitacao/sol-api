require 'rails_helper'

RSpec.describe Contract::SystemRefuseWorker, type: :worker do
  let(:service) { ContractsService::SystemRefuse }
  let(:service_method) { :call! }

  include_examples 'workers/perform_without_params'
end
