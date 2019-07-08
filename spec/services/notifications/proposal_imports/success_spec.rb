require 'rails_helper'

RSpec.describe Notifications::ProposalImports::Success, type: [:service, :notification] do
  let(:resource) do
    create(:proposal_import, bidding: bidding, provider: provider)
  end
  let(:args) { { proposal_import: resource, supplier: user } }
  let(:extra_args) { { bidding_id: bidding.id }.as_json }
  let(:title_msg) { 'Propostas importadas.' }
  let(:body_args) { [bidding.title, resource.file.filename] }
  let(:body_msg) do
    "As propostas da licitação \"#{bidding.title}\" do arquivo <strong>#{resource.file.filename}</strong> foram importadas com sucesso."
  end

  include_examples 'services/concerns/proposal_import_notification', 'success'
end
