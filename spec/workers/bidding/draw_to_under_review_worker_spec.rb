require 'rails_helper'

RSpec.describe Bidding::DrawToUnderReviewWorker, type: :worker do
  let(:service) { BiddingsService::DrawToUnderReview }
  let(:service_method) { :call }

  include_examples 'workers/perform_without_params'
end
