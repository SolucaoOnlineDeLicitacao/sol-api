require 'rails_helper'

RSpec.describe Bidding::ApprovedToOngoingWorker, type: :worker do
  let(:service) { BiddingsService::ApprovedToOngoing }
  let(:service_method) { :call }

  include_examples 'workers/perform_without_params'
end
