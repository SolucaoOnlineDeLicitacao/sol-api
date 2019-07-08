require 'rails_helper'

RSpec.describe Administrator::Biddings::CancellationRequests::ApprovesController, type: :controller do
  let(:service) { BiddingsService::CancellationRequests::Approve }

  it_behaves_like 'a cancellation event request'
end
