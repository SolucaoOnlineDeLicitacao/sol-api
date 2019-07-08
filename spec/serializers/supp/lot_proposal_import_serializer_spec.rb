require 'rails_helper'

RSpec.describe Supp::LotProposalImportSerializer, type: :serializer do
  let(:object) { create :lot_proposal_import }

  include_examples "serializers/concerns/base_proposal_import_serializer"

  describe 'lot attributes' do
    it { is_expected.to include 'lot_id' => object.lot.id }
    it { is_expected.to include 'lot_name' => object.lot.name }
  end
end
