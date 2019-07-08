require 'rails_helper'

RSpec.describe ProposalService::Draw, type: :service do
  let(:service) { described_class.new(bidding) }

  describe 'initialization' do
    let(:bidding) { create(:bidding, kind: :global, status: :ongoing) }

    it { expect(service.bidding).to eq bidding }
    it { expect(service.has_draw).to be_falsy }
  end

  describe 'call' do
    context 'when global kind' do
      let!(:bidding) { create(:bidding, kind: :global, status: :ongoing) }
      let!(:lot_1) { bidding.lots.first }

      context 'with proposals and not draw' do
        let!(:proposal_a_lot_1) { create(:proposal, bidding: bidding, lot: lot_1, status: :sent, price_total: 5000) }

        before do
          allow(ProposalService::Draw::Global).to receive(:call).with(bidding) { true }

          service.call
        end

        it { expect(ProposalService::Draw::Global).to have_received(:call).with(bidding) }
        it { expect(service.has_draw).to be_truthy }
      end

      context 'without proposals' do
        before do
          allow(ProposalService::Draw::Global).to receive(:call).with(bidding) { true }

          service.call
        end

        it { expect(ProposalService::Draw::Global).not_to have_received(:call).with(bidding) }
      end

      context 'when proposal is draft' do
        let!(:proposal_a_lot_1) { create(:proposal, bidding: bidding, lot: lot_1, status: :draft, price_total: 5000) }

        before do
          bidding.draw!

          allow(ProposalService::Draw::Global).to receive(:call).with(bidding) { true }

          service.call
        end

        it { expect(ProposalService::Draw::Global).not_to have_received(:call).with(bidding) }
      end

      context 'when bidding is draw' do
        before do
          bidding.draw!

          allow(ProposalService::Draw::Global).to receive(:call).with(bidding) { true }

          service.call
        end

        it { expect(ProposalService::Draw::Global).not_to have_received(:call).with(bidding) }
      end
    end

    context 'when not global kind' do
      let!(:bidding) { create(:bidding, kind: :lot) }
      let!(:lot_1) { bidding.lots.first }
      let!(:lot_2) { create(:lot, bidding: bidding) }
      let!(:lot_3) { create(:lot, bidding: bidding) }

      before { Proposal.skip_callback(:commit, :after, :update_price_total) }
      after { Proposal.set_callback(:commit, :after, :update_price_total) }

      context 'with empty proposals' do
        before do
          allow(service).to receive(:resolve_draw!) { true }

          service.call
        end

        it { expect(service).not_to have_received(:resolve_draw!) }
      end

      context 'when draw' do
        before do
          bidding.draw!

          allow(service).to receive(:resolve_draw!) { true }
          service.call
        end

        it { expect(service).not_to have_received(:resolve_draw!) }
      end

      context 'with proposals and not draw' do
        let!(:proposal_a_lot_1) { create(:proposal, bidding: bidding, lot: lot_1, status: :sent, price_total: 5000) }
        let!(:proposal_b_lot_1) { create(:proposal, bidding: bidding, lot: lot_1, status: :sent, price_total: 5000) }
        let!(:proposal_c_lot_1) { create(:proposal, bidding: bidding, lot: lot_1, status: :sent, price_total: 6000) }

        let!(:proposal_a_lot_2) { create(:proposal, bidding: bidding, lot: lot_2, status: :sent, price_total: 1000) }
        let!(:proposal_b_lot_2) { create(:proposal, bidding: bidding, lot: lot_2, status: :sent, price_total: 1000) }
        let!(:proposal_c_lot_2) { create(:proposal, bidding: bidding, lot: lot_2, status: :sent, price_total: 2000) }

        let!(:proposal_a_lot_3) { create(:proposal, bidding: bidding, lot: lot_3, status: :sent, price_total: 1000) }
        let!(:proposal_b_lot_3) { create(:proposal, bidding: bidding, lot: lot_3, status: :sent, price_total: 1100) }

        before { service.call }

        it { expect(proposal_a_lot_1.reload.draw?).to be_truthy }
        it { expect(proposal_b_lot_1.reload.draw?).to be_truthy }
        it { expect(proposal_c_lot_1.reload.draw?).to be_falsy }

        it { expect(proposal_a_lot_2.reload.draw?).to be_truthy }
        it { expect(proposal_b_lot_2.reload.draw?).to be_truthy }
        it { expect(proposal_c_lot_2.reload.draw?).to be_falsy }

        it { expect(proposal_a_lot_3.reload.draw?).to be_falsy }
        it { expect(proposal_b_lot_3.reload.draw?).to be_falsy }

        it { expect(service.has_draw).to be_truthy }
        it { expect(bidding.reload.draw?).to be_truthy }
      end
    end
  end
end
