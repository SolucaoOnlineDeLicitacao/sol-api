require 'rails_helper'

RSpec.describe Pdf::Contract::TemplateStrategy do
  include_examples 'services/concerns/init_contract'

  let(:covenant) { bidding.covenant }
  let(:cooperative) { covenant.cooperative }
  let(:bidding) { create(:bidding, status: :finnished, kind: :global, classification: classification) }
  let(:proposal) { create(:proposal, bidding: bidding, provider: provider, status: :accepted) }
  let(:user) { create(:user, cooperative: cooperative) }
  let(:admin) { create(:admin) }
  let!(:contract) do
    create(:contract, proposal: proposal,
                      user: user, user_signed_at: DateTime.current,
                      supplier: supplier, supplier_signed_at: DateTime.current)
  end
  let(:params) { { contract: contract } }

  describe '#decide' do
    subject { described_class.decide(params) }

    context 'when classification is bens' do
      let(:classification) { create(:classification, name: 'BENS') } 

      it { expect(subject).to be_kind_of(Pdf::Contract::Classification::Commodity) }  
    end

    context 'when classification is serviço' do
      let(:classification) { create(:classification, name: 'SERVIÇOS') } 

      it { expect(subject).to be_kind_of(Pdf::Contract::Classification::Service) }  
    end

    context 'when classification is obras' do
      let(:classification) { create(:classification, name: 'OBRAS') } 

      it { expect(subject).to be_kind_of(Pdf::Contract::Classification::Work) }  
    end

  end
end
