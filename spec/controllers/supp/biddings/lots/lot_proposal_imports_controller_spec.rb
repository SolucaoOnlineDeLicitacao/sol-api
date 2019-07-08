require 'rails_helper'

RSpec.describe Supp::Biddings::Lots::LotProposalImportsController, type: :controller do
  let(:lots) { bidding.lots }
  let(:lot) { lots.first }
  let(:resource) do
    create(:lot_proposal_import, bidding: bidding, provider: provider)
  end
  let(:base_params) { { bidding_id: bidding, lot_id: lot } }

  include_examples 'controllers/concerns/imports_controller'
end
