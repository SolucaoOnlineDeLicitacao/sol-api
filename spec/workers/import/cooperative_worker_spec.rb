require 'rails_helper'

RSpec.describe Import::CooperativeWorker, type: :worker do
  let(:service) { Integration::Cooperative::Import }
  let(:service_method) { :call }

  include_examples 'workers/perform_without_params'
end
