RSpec.shared_examples 'services/concerns/proposal' do |status|

  let!(:contract_status) { status[:contract_status] }

  include_examples 'services/concerns/init_contract'

  before { Proposal.skip_callback(:commit, :after, :update_price_total) }
  after { Proposal.set_callback(:commit, :after, :update_price_total) }

  let(:service) { described_class.new(contract: contract) }

  let(:api_response) { true }
  before { allow(Blockchain::Contract::Update).to receive(:call!).with(contract: contract) { api_response } }

  subject(:service_call) { service.call }

  describe '#initializer' do
    it { expect(service.contract).to eq contract }
  end

  describe '.call' do
    context 'when success' do
      describe 'when have more than one proposal' do
        let(:proposals) { bidding.proposals.where(status: [:sent, :accepted, :refused]) }
        let!(:proposal_2) { create(:proposal, bidding: bidding, provider: provider, price_total: 1000, status: :sent) }
        let!(:proposal_3) { create(:proposal, bidding: bidding, provider: provider, price_total: 300, status: :accepted) }
        let!(:proposal_4) { create(:proposal, bidding: bidding, provider: provider, price_total: 500, status: :refused) }

        before do
          allow(BiddingsService::Proposals::Retry).to receive(:call!) { true }
          allow(BiddingsService::Cancel).to receive(:call!) { true }
          allow(BiddingsService::Clone).to receive(:call!) { true }

          service_call
        end

        it { expect(contract.send("#{contract_status}?")).to be_truthy }

        let(:lot_2) { proposal_2.lots.first }

        it { expect(proposal.failure?).to be_truthy }
        it { expect(proposal_2.reload.sent?).to be_truthy }
        it { expect(bidding.reload.reopen_reason_contract_id).to eq(contract.id) }
        it { expect(BiddingsService::Proposals::Retry).to have_received(:call!).with(bidding: bidding, proposal: proposal) }

      end

      describe 'when have one proposal' do
        before do
          allow(BiddingsService::Cancel).to receive(:call!) { true }
          allow(BiddingsService::Clone).to receive(:call!) { true }

          service_call
        end

        it { expect(contract.send("#{contract_status}?")).to be_truthy }
        it { expect(proposal.failure?).to be_truthy }
        it { expect(bidding.reload.reopen_reason_contract_id).to eq(contract.id) }
      end
    end

    context 'when RecordInvalid error' do
      let!(:api_response) { double('api_response', success?: true) }

      before do
        allow(contract).to receive("#{contract_status}!".to_sym) { raise ActiveRecord::RecordInvalid }

        service_call
      end

      it { expect(contract.send("#{contract_status}?")).to be_falsy }
      it { expect(service_call).to be_falsy }
      it { expect(bidding.reload.reopen_reason_contract).to be_nil }
    end

    context 'when BC error' do
      before do
        allow(BiddingsService::Proposals::Retry).to receive(:call!) { true }
        allow(BiddingsService::Cancel).to receive(:call) { true }
        allow(BiddingsService::Clone).to receive(:call) { true }
        allow(Blockchain::Contract::Update).to receive(:call!) { raise BlockchainError }
      end

      it { expect(contract.reload.send("#{contract_status}?")).to be_falsy }
      it { expect(service_call).to be_falsy }
      it { expect(bidding.reload.reopen_reason_contract).to be_nil }
    end
  end
end
