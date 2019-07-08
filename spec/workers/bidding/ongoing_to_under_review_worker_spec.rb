require 'rails_helper'

RSpec.describe Bidding::OngoingToUnderReviewWorker, type: :worker do
  let(:service) { BiddingsService::OngoingToUnderReview }
  let(:service_method) { :call }

  include_examples 'workers/perform_without_params'
end
