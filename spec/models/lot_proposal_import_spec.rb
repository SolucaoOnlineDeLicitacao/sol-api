require 'rails_helper'

RSpec.describe LotProposalImport, type: :model do
  include_examples 'concerns/importable'

  context 'when lot' do
    describe 'associations' do
      it { is_expected.to belong_to(:lot) }
    end
  end
end
