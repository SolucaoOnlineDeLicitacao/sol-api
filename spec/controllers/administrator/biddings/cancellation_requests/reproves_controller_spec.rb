require 'rails_helper'

RSpec.describe Administrator::Biddings::CancellationRequests::ReprovesController, type: :controller do
  let(:service) { BiddingsService::CancellationRequests::Reprove }

  it_behaves_like 'a cancellation event request'
end
