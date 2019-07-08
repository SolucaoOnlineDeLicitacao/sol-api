require 'rails_helper'

RSpec.describe ContractsService::Create::Strategy::Reopened, type: :service do
  let!(:user)  { create(:user) }
  let!(:lot_1) { create(:lot) }
  let!(:lot_2) { create(:lot) }
  let!(:lot_3) { create(:lot) }
  let!(:provider) { create(:provider) }
  let!(:bidding) do
    create(:bidding, build_lot: false, lots: [lot_1, lot_2, lot_3], status: :finnished, kind: :global)
  end
  let!(:proposal) do
    create(:proposal, bidding: bidding, provider: provider, status: :accepted)
  end
  let!(:contract) do
    create(:contract, proposal: proposal, user: user, status: :total_inexecution,
                      user_signed_at: DateTime.current)
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
      let!(:lot_1) { create(:lot) }
      let!(:lot_2) { create(:lot) }
      let!(:lot_3) { create(:lot) }
      let!(:bidding_lot) do
        create(:bidding, build_lot: false, lots: [lot_1, lot_2, lot_3], status: :finnished, kind: :lot)
      end
      let!(:contract) do
        create(:contract, proposal: proposal_a_lot_1, user: user, status: :total_inexecution,
                          user_signed_at: DateTime.current)
      end
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
