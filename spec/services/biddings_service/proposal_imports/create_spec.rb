require 'rails_helper'

RSpec.describe BiddingsService::ProposalImports::Create, type: :service do
  let(:resource) do
    build(:proposal_import, bidding: bidding, provider: provider)
  end
  let(:args) do
    { proposal_import: resource, user: user, bidding: bidding }
  end

  include_examples 'services/concerns/create_import'
end
