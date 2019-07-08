require 'rails_helper'

RSpec.describe ReportsService::Classification, type: :service do
  let(:service_call) { described_class.call }
  let!(:classification_1) { create(:classification, name: 'BENS') }
  let!(:classification_2) { create(:classification, name: 'OBRAS') }
  let!(:classification_3) { create(:classification, name: 'SERVIÇOS') }
  let!(:classification_4) do
    create(:classification, name: 'BENS 2', classification_id: classification_3.id)
  end

  before { Proposal.skip_callback(:commit, :after, :update_price_total) }
  after { Proposal.set_callback(:commit, :after, :update_price_total) }

  describe '.call' do
    include_examples 'services/concerns/contract_classification'

    let(:result) do
      [
        {
          classification: classification_1,
          contracts: [contract_4],
          price_total: proposal_4.price_total
        },
        {
          classification: classification_2,
          contracts: [contract_2],
          price_total: proposal_2.price_total
        },
        {
          classification: classification_3,
          contracts: [contract_3],
          price_total: proposal_3.price_total
        },
        {
          classification: classification_4,
          contracts: [],
          price_total: 0
        }
      ]
    end

    before do
      proposal_2.accepted!
      proposal_3.accepted!
      proposal_4.accepted!
    end

    it { expect(service_call).to eq result }
  end
end
