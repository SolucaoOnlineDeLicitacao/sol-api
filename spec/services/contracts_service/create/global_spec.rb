require 'rails_helper'

RSpec.describe ContractsService::Create::Global, type: :service do

  before { Proposal.skip_callback(:commit, :after, :update_price_total) }
  after { Proposal.set_callback(:commit, :after, :update_price_total) }

  let!(:user) { create(:user) }
  let!(:bidding) { create(:bidding, status: :finnished, kind: :global) }
  let!(:lot_1) { bidding.lots.first }
  let!(:lot_2) { create(:lot, bidding: bidding) }
  let!(:lot_3) { create(:lot, bidding: bidding) }

  let!(:provider) { create(:provider) }

  let!(:proposal) do
    create(:proposal, bidding: bidding, provider: provider, status: :accepted)
  end

  subject(:service) { described_class.new(bidding: bidding, user: user) }

  before do
    allow(Blockchain::Contract::Create).to receive(:call!) { true }
    allow(Notifications::Contracts::Created).to receive(:call) { true }
  end

  describe '#initialize' do
    it { expect(subject.bidding).to eq bidding }
    it { expect(subject.user).to eq user }
  end

  describe '.call!' do
    subject { service.call! }

    context 'when create! fails' do
      before { allow(Contract).to receive(:create!) { raise ActiveRecord::RecordInvalid } }

      it { expect{ subject }.to raise_error CreateContractError }
    end

    context 'when BC fails' do
      before do
        allow(Contract).to receive(:create!) { true }
        allow(Blockchain::Contract::Create).to receive(:call!) { raise BlockchainError }
      end

      it { expect{ subject }.to raise_error CreateContractError }
    end

    context 'when create! succeeds' do
      before do
        allow(Contract).to receive(:create!) { true }
        subject
      end

      it { expect{ subject }.not_to raise_error }
      it { expect(Notifications::Contracts::Created).to have_received(:call) }
    end

    context 'when already has a contract' do
      let!(:contract) { create(:contract, proposal: proposal, user: user, deleted_at: Date.today) }

      it { expect { subject }.not_to change { Contract.count } }
    end

    context 'when bidding has no proposal' do
      let!(:proposal) { create(:proposal, provider: provider, status: :accepted) }
      let(:contract) { Contract.where(user: user) }

      before { subject }

      it { expect(contract).not_to be_present }
    end

    context 'when global bidding' do
      before do
        lot_1.accepted!
        lot_2.accepted!
        lot_3.accepted!
      end

      let(:contract) { Contract.where(proposal: proposal, user: user) }

      context 'when lots havent a deadline and get deadline bidding' do
        before do
          allow(ContractsService::CalculateDeadline).to receive(:call) { deadline }
          subject
        end

        let(:deadline) { bidding.deadline + 60 }

        it { expect(contract).to be_present }
        it { expect(contract.first.deadline).to eq deadline }
        it do
          expect(ContractsService::CalculateDeadline).
            to have_received(:call).with(lots: bidding.lots.accepted)
        end
        it { expect(Notifications::Contracts::Created).to have_received(:call) }
      end

      context 'when lots have a deadline' do
        before do
          allow(ContractsService::CalculateDeadline).to receive(:call) { deadline }
          lot_1.update(deadline: 2)
          lot_2.update(deadline: 5)
          lot_3.update(deadline: 3)
          subject
        end

        let(:deadline) { lot_2.deadline + 60 }

        it { expect(contract.first.deadline).to eq deadline }
        it do
          expect(ContractsService::CalculateDeadline).
            to have_received(:call).with(lots: bidding.lots.accepted)
        end
        it { expect(Notifications::Contracts::Created).to have_received(:call) }
      end

      context 'when 1 lot is not accepted' do
        before do
          allow(ContractsService::CalculateDeadline).to receive(:call) { deadline }
          lot_1.update(deadline: 2)
          lot_3.update(deadline: 3)
          lot_2.failure!
          subject
        end

        let(:deadline) { lot_3.deadline + 60 }

        it { expect(contract.first.deadline).to eq deadline }
        it do
          expect(ContractsService::CalculateDeadline).
            to have_received(:call).with(lots: bidding.lots.accepted)
        end
        it { expect(Notifications::Contracts::Created).to have_received(:call) }
      end
    end
  end
end
