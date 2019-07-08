require 'rails_helper'

RSpec.describe ContractsService::Proposals::Refused, type: :service do
  include_examples 'services/concerns/proposal', contract_status: :refused

  describe '#assign_deleted_at' do
    include_examples 'services/concerns/init_contract'

    before do
      allow(DateTime).to receive(:current) { DateTime.new(2018, 1, 1, 0, 0, 0) }
      described_class.call(contract: contract)
    end

    it { expect(contract.deleted_at).to eq DateTime.current }
  end
end
