require 'rails_helper'

RSpec.describe ContractsService::Proposals::TotalInexecution, type: :service do
  before do
    allow(Notifications::Contracts::TotalInexecution).
      to receive(:call).with(contract: contract).and_return(true)

    allow(Blockchain::Contract::Update).to receive(:call!).and_return(true)
  end

  subject(:service_call) { described_class.call(contract: contract) }

  context 'when the bidding type is global' do
    include_examples 'services/concerns/proposal', contract_status: :total_inexecution
  end

  context 'when the bidding have only one proposal' do
    include_examples 'services/concerns/init_contract'

    context 'when success' do
      before do
        allow(BiddingsService::Proposals::Retry).
          to receive(:call!).and_return(true)

        service_call
      end

      it { expect(BiddingsService::Proposals::Retry).not_to have_received(:call!) }
    end
  end

  context 'when the bidding type are lots' do
    describe '.call' do
      include_examples 'services/concerns/init_contract_lot'

      let(:contract_bidding) { contract.bidding }
      let(:report_worker) { Bidding::SpreadsheetReportGenerateWorker }

      context 'when success' do
        let(:contract_proposal) { contract.proposal }

        before do
          allow(BiddingsService::Proposals::Retry).
            to receive(:call!).and_return(true)

          service_call
        end

        it { expect(contract.total_inexecution?).to be_truthy }
        it { expect(proposal_c_lot_1.reload.failure?).to be_truthy }
        it { expect(contract_bidding.reopen_reason_contract).to be_instance_of(Contract) }
        it do
          expect(BiddingsService::Proposals::Retry).
            to have_received(:call!).
            with(bidding: contract_bidding, proposal: contract_proposal)
        end
        it do
          expect(Notifications::Contracts::TotalInexecution).
            to have_received(:call).with(contract: contract)
        end
        it { expect(report_worker.jobs.size).to eq(1) }
      end

      context 'when RecordInvalid error' do
        before do
          allow(contract).
            to receive(:total_inexecution!).
            and_raise(ActiveRecord::RecordInvalid)

          service_call
        end

        it { expect(contract.reload.total_inexecution?).to be_falsy }
        it { expect(service_call).to be_falsy }
        it { expect(contract_bidding.reopen_reason_contract).to be_nil }
        it do
          expect(Notifications::Contracts::TotalInexecution).
            to_not have_received(:call).with(contract: contract)
        end
        it { expect(report_worker.jobs.size).to eq(0) }
      end

      context 'when BC error' do
        before do
          allow(Blockchain::Contract::Update).
            to receive(:call!).with(contract: contract).
            and_raise(BlockchainError)
        end

        it { expect(contract.reload.total_inexecution?).to be_falsy }
        it { expect(service_call).to be_falsy }
        it { expect(contract_bidding.reopen_reason_contract).to be_nil }
        it do
          expect(Notifications::Contracts::TotalInexecution).
            to_not have_received(:call).with(contract: contract)
        end
        it { expect(report_worker.jobs.size).to eq(0) }
      end
    end
  end

  context 'when contract is not signed' do
    let(:user) { create(:user) }
    let(:bidding) { create(:bidding) }
    let(:proposal) { create(:proposal, bidding: bidding) }
    let(:contract) do
      create(:contract, proposal: proposal, user: user, user_signed_at: DateTime.current)
    end

    it { is_expected.to be_falsy }
  end
end
