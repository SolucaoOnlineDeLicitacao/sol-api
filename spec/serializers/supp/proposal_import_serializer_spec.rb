require 'rails_helper'

RSpec.describe Supp::ProposalImportSerializer, type: :serializer do
  let(:object) { create :proposal_import }

  include_examples "serializers/concerns/base_proposal_import_serializer"
end
