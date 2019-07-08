require 'rails_helper'

RSpec.describe Notifications::ProposalImports::Lots::Success, type: [:service, :notification] do
  let(:resource) do
    create(:lot_proposal_import, bidding: bidding, provider: provider)
  end
  let(:lot) { resource.lot }
  let(:args) { { lot_proposal_import: resource, supplier: user } }
  let(:extra_args) { { bidding_id: bidding.id, lot_id: lot.id }.as_json }
  let(:title_msg) { 'Proposta importada.' }
  let(:body_args) { [lot.name, resource.file.filename] }
  let(:body_msg) do
    "A proposta do lote \"#{lot.name}\" do arquivo <strong>#{resource.file.filename}</strong> foi importada com sucesso."
  end

  include_examples 'services/concerns/proposal_import_notification', 'lot_success'
end
