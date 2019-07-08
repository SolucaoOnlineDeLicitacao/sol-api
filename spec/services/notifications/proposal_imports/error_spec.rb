require 'rails_helper'

RSpec.describe Notifications::ProposalImports::Error, type: [:service, :notification] do
  let(:resource) do
    create(:proposal_import, bidding: bidding, provider: provider)
  end
  let(:args) { { proposal_import: resource, supplier: user } }
  let(:extra_args) { { bidding_id: bidding.id }.as_json }
  let(:title_msg) { 'Propostas não importadas.' }
  let(:body_args) { [bidding.title, resource.file.filename] }
  let(:body_msg) do
    "Não foi possível realizar a importação da proposta da licitação \"#{bidding.title}\"."\
    " Verifique o arquivo <strong>#{resource.file.filename}</strong> e tente novamente."
  end

  include_examples 'services/concerns/proposal_import_notification', 'error'
end
