require 'rails_helper'

RSpec.describe ContractsService::Completed, type: :service do
  include_examples 'services/concerns/init_contract'

  let(:params) { { contract: contract } }

  before do
    allow(Notifications::Contracts::Completed).
      to receive(:call).with(contract: contract).and_return(true)

    allow(Blockchain::Contract::Update).
      to receive(:call!).with(contract: contract).and_return(true)
  end

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.contract).to eq contract }
  end

  describe '.call' do
    subject { described_class.call(params) }

    context 'when success' do
      before { subject }

      it { expect(contract.completed?).to be_truthy }
      it do
        expect(Blockchain::Contract::Update).
          to have_received(:call!).with(contract: contract)
      end
      it do
        expect(Notifications::Contracts::Completed).
          to have_received(:call).with(contract: contract)
      end
    end

    context 'when RecordInvalid error' do
      before do
        allow(contract).
          to receive(:completed!).and_raise(ActiveRecord::RecordInvalid)
      end

      it { is_expected.to be_falsey }
      it do
        expect(Blockchain::Contract::Update).
          to_not have_received(:call!).with(contract: contract)
      end
      it do
        expect(Notifications::Contracts::Completed).
          to_not have_received(:call).with(contract: contract)
      end
    end

    context 'when BC error' do
      before do
        allow(Blockchain::Contract::Update).
          to receive(:call!).and_raise(BlockchainError)
      end

      it { is_expected.to be_falsey }
      it do
        expect(Blockchain::Contract::Update).
          to_not have_received(:call!).with(contract: contract)
      end
      it do
        expect(Notifications::Contracts::Completed).
          to_not have_received(:call).with(contract: contract)
      end
    end
  end

  describe '.call!' do
    subject { described_class.call!(params) }

    context 'when success' do
      before { subject }

      it { expect(contract.completed?).to be_truthy }
      it do
        expect(Blockchain::Contract::Update).
          to have_received(:call!).with(contract: contract)
      end
      it do
        expect(Notifications::Contracts::Completed).
          to have_received(:call).with(contract: contract)
      end
    end

    context 'when RecordInvalid error' do
      before do
        allow(contract).
          to receive(:completed!).and_raise(ActiveRecord::RecordInvalid)
      end

      it { expect { subject }.to raise_error(ActiveRecord::RecordInvalid) }
      it do
        expect(Blockchain::Contract::Update).
          to_not have_received(:call!).with(contract: contract)
      end
      it do
        expect(Notifications::Contracts::Completed).
          to_not have_received(:call).with(contract: contract)
      end
    end

    context 'when BC error' do
      before do
        allow(Blockchain::Contract::Update).
          to receive(:call!).and_raise(BlockchainError)
      end

      it { expect { subject }.to raise_error(ActiveRecord::RecordInvalid) }
      it do
        expect(Blockchain::Contract::Update).
          to_not have_received(:call!).with(contract: contract)
      end
      it do
        expect(Notifications::Contracts::Completed).
          to_not have_received(:call).with(contract: contract)
      end
    end
  end
end
