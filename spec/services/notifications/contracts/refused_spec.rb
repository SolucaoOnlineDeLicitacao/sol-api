require 'rails_helper'

RSpec.describe Notifications::Contracts::Refused, type: [:service, :notification] do
  include_examples 'services/concerns/init_contract'

  let(:params) { { contract: contract } }
  let(:service) { described_class.new(params) }

  describe '#initialize' do
    subject { service }

    it { expect(subject.contract).to eq contract }
  end

  describe '.call' do
    let(:refuser) { supplier }

    before do
      allow(Notifications::Contracts::Refused::User).
        to receive(:call).with(contract: contract)
      allow(Notifications::Contracts::Refused::Supplier).
        to receive(:call).with(contract: contract)

      contract.refused_by!(refuser)

      subject
    end

    subject { described_class.call(params) }

    it do
      expect(Notifications::Contracts::Refused::User).
        to have_received(:call).with(contract: contract)
    end

    context 'when it is refused by Admin' do
      let(:refuser) { create(:admin) }

      it do
        expect(Notifications::Contracts::Refused::Supplier).
          to_not have_received(:call).with(contract: contract)
      end
    end

    context 'when it is refused by Supplier' do
      it do
        expect(Notifications::Contracts::Refused::Supplier).
          to have_received(:call).with(contract: contract)
      end
    end
  end
end
