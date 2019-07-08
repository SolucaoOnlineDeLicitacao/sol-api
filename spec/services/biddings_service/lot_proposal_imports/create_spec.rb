require 'rails_helper'

RSpec.describe BiddingsService::LotProposalImports::Create, type: :service do
  let(:lots) { bidding.lots }
  let(:lot) { lots.first }
  let(:resource) do
    build(:lot_proposal_import, bidding: bidding, provider: provider)
  end
  let(:args) do
    { lot_proposal_import: resource, user: user, bidding: bidding, lot: lot,
      file: resource.file }
  end

  include_examples 'services/concerns/create_import'
end
