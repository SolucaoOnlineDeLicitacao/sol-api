require 'rails_helper'

RSpec.describe ContractsService::Sign, type: :service do
  include_examples 'services/concerns/init_contract'

  let(:contract) do
    create(:contract, proposal: proposal,
                      user: user, user_signed_at: DateTime.current,
                      supplier: supplier, supplier_signed_at: DateTime.current)
  end
  let(:person) { supplier }
  let(:params) do
    { contract: contract, type: person.class.name.downcase, user: person }
  end
  let(:all_signed) { true }

  before do
    allow(Blockchain::Contract::Update).
      to receive(:call!).with(contract: contract).and_return(true)
  end

  describe '#initialize' do
    subject { described_class.new(params) }

    context 'when supplier type' do
      it { expect(subject.user).to eq supplier }
      it { expect(subject.contract).to eq contract }
    end
  end

  describe '.call' do
    let(:worker) { Contract::PdfGenerateWorker }

    before do
      allow(Notifications::Contracts::Sign::AdminUser).
        to receive(:call).with(contract: contract).and_return(true)

      allow(contract).to receive(:all_signed?).and_return(all_signed)
    end

    subject { described_class.call(params) }

    context 'when success' do
      before do
        subject
        contract.reload
      end

      context 'and all signed' do
        it { expect(contract.signed?).to be_truthy }
        it { expect(contract).to be_signed }
        it { expect(contract.supplier).to eq supplier }
        it { is_expected.to be_truthy }
        it do
          expect(Notifications::Contracts::Sign::AdminUser).
            to have_received(:call).with(contract: contract)
        end
        it { expect(worker.jobs.size).to eq(1) }
      end

      context 'and not all signed' do
        let(:all_signed) { false }

        it { expect(contract.signed?).to be_falsey }
        it { expect(contract).not_to be_signed }
        it { expect(contract.supplier).to eq supplier }
        it { is_expected.to be_truthy }
        it do
          expect(Notifications::Contracts::Sign::AdminUser).
            to have_received(:call).with(contract: contract)
        end
        it { expect(worker.jobs.size).to eq(0) }
      end

      context 'when supplier type' do
        let(:person) { supplier }

        it do
          expect(Notifications::Contracts::Sign::AdminUser).
            to have_received(:call).with(contract: contract)
        end
      end
    end

    context 'when BC error' do
      before do
        allow(Blockchain::Contract::Update).
          to receive(:call!).with(contract: contract).and_raise(BlockchainError)

        subject
        contract.reload
      end

      it { expect(contract.signed?).to be_falsey }
      it { expect(contract).not_to be_signed }
      it { expect(contract.user).not_to eq supplier }
      it { is_expected.to be_falsey }
      it do
        expect(Notifications::Contracts::Sign::AdminUser).
          not_to have_received(:call).with(contract: contract)
      end
      it { expect(worker.jobs.size).to eq(0) }
    end

    context 'when RecordInvalid error' do
      before do
        allow(contract).
          to receive(:save!).and_raise(ActiveRecord::RecordInvalid)

        subject
        contract.reload
      end

      it { expect(contract.signed?).to be_falsey }
      it { expect(contract).not_to be_signed }
      it { expect(contract.user).not_to eq supplier }
      it { is_expected.to be_falsy }
      it do
        expect(Notifications::Contracts::Sign::AdminUser).
          not_to have_received(:call).with(contract: contract)
      end
      it { expect(worker.jobs.size).to eq(0) }
    end
  end
end
