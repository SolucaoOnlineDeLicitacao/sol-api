require 'rails_helper'

RSpec.describe ContractsService::Create::Strategy::Finnished, type: :service do
  let!(:user)     { create(:user) }
  let!(:bidding)  { create(:bidding, status: :finnished, kind: :global) }
  let!(:lot_1) { bidding.lots.first }
  let!(:lot_2) { create(:lot, bidding: bidding) }
  let!(:lot_3) { create(:lot, bidding: bidding) }
  let!(:provider) { create(:provider) }

  let!(:proposal) do
    create(:proposal, bidding: bidding, provider: provider, status: :accepted)
  end

  subject(:service) { described_class.new(bidding: bidding, user: user) }

  describe '#initializer' do
    it { expect(service.bidding).to eq bidding }
    it { expect(service.user).to eq user }
  end

  describe '.call!' do
    subject { service.call! }

    context 'when global bidding' do
      before do
        allow(ContractsService::Create::Global).to receive(:call!).with(bidding: bidding, user: user).and_call_original
        subject
      end

      it { expect(ContractsService::Create::Global).
          to have_received(:call!).with(bidding: bidding, user: user) }
    end

    context 'when lot/item bidding' do
      include_examples 'services/concerns/init_bidding_lot'
      let(:service)   { described_class.new(bidding: bidding_lot, user: user) }

      before do
        allow(ContractsService::Create::Lot).to receive(:call!).with(lot: lot_1, user: user).and_call_original
        allow(ContractsService::Create::Lot).to receive(:call!).with(lot: lot_2, user: user).and_call_original
        allow(ContractsService::Create::Lot).to receive(:call!).with(lot: lot_3, user: user).and_call_original
        lot_1.send("#{status}!")
        lot_2.send("#{status}!")
        lot_3.send("#{status}!")
        subject
      end

      context 'with accepted lot' do
        let(:status) { :accepted }

        it { expect(ContractsService::Create::Lot).
          to have_received(:call!).with(lot: lot_1, user: user) }
        it { expect(ContractsService::Create::Lot).
          to have_received(:call!).with(lot: lot_2, user: user) }
        it { expect(ContractsService::Create::Lot).
          to have_received(:call!).with(lot: lot_3, user: user) }
      end

      context 'without accepted lot' do
        let(:status) { :failure }

        it { expect(ContractsService::Create::Lot).
          not_to have_received(:call!).with(lot: lot_1, user: user) }
        it { expect(ContractsService::Create::Lot).
          not_to have_received(:call!).with(lot: lot_2, user: user) }
        it { expect(ContractsService::Create::Lot).
          not_to have_received(:call!).with(lot: lot_3, user: user) }
      end
    end
  end
end
