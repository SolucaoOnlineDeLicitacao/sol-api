require 'rails_helper'

RSpec.describe Supp::Biddings::ProposalImportsController, type: :controller do
  let(:resource) do
    create(:proposal_import, bidding: bidding, provider: provider)
  end
  let(:base_params) { { bidding_id: bidding } }

  include_examples 'controllers/concerns/imports_controller'
end
