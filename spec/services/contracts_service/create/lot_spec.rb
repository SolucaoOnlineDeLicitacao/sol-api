require 'rails_helper'

RSpec.describe ContractsService::Create::Lot, type: :service do

  before { Proposal.skip_callback(:commit, :after, :update_price_total) }
  after { Proposal.set_callback(:commit, :after, :update_price_total) }

  include_examples 'services/concerns/init_bidding_lot'

  subject(:service) { described_class.new(lot: lot_2, user: user) }

  before do
    allow(Blockchain::Contract::Create).to receive(:call!) { true }
    allow(Notifications::Contracts::Created).to receive(:call) { true }
  end

  describe '#initialize' do
    it { expect(subject.lot).to eq lot_2 }
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
      let!(:contract) { create(:contract, proposal: proposal_b_lot_2, user: user, deleted_at: Date.today) }

      it { expect { subject }.not_to change { Contract.count } }
    end

    context 'when lot/item bidding' do
      before { lot_2.send("#{status}!") }

      let(:proposal_1) { proposal_b_lot_2 }

      context 'with accepted lot' do
        let(:status)   { :accepted }
        let(:contract_1) { Contract.where(proposal: proposal_1, user: user) }

        context 'with accepted proposal' do
          before { subject }

          it { expect(contract_1).to be_present }
        end

        context 'when lots havent a deadline and get deadline bidding' do
          before do
            allow(ContractsService::CalculateDeadline).to receive(:call) { deadline }
            subject
          end

          let(:deadline) { bidding_lot.deadline + 60 }

          it { expect(contract_1.first.deadline).to eq deadline }
          it do
            expect(ContractsService::CalculateDeadline).
              to have_received(:call).with(lots: [lot_2])
          end
          it { expect(Notifications::Contracts::Created).to have_received(:call) }
        end

        context 'when lots have a deadline' do
          before do
            lot_1.update(deadline: 2)
            lot_2.update(deadline: 5)
            lot_3.update(deadline: 3)
            allow(ContractsService::CalculateDeadline).to receive(:call) { deadline_1 }

            subject
          end

          let(:deadline_1) { lot_2.deadline + 60 }

          it { expect(contract_1.first.deadline).to eq deadline_1 }
          it do
            expect(ContractsService::CalculateDeadline).
              to have_received(:call).with(lots: [lot_2])
          end
          it { expect(Notifications::Contracts::Created).to have_received(:call) }
        end

        context 'without accepted proposal' do
          before { proposal_1.draft! }

          it { expect(contract_1).not_to be_present }
        end
      end
    end
  end
end
