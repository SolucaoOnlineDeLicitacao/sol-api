require 'rails_helper'

RSpec.describe Import::CovenantWorker, type: :worker do
  let(:service) { Integration::Covenant::Import }
  let(:service_method) { :call }

  include_examples 'workers/perform_without_params'
end
