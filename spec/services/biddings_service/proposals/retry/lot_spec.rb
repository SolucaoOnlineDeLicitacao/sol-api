require 'rails_helper'

RSpec.describe BiddingsService::Proposals::Retry::Lot, type: :service do
  let(:params) { { bidding: bidding, proposal: proposal } }

  before { Proposal.skip_callback(:commit, :after, :update_price_total) }

  after { Proposal.set_callback(:commit, :after, :update_price_total) }

  describe '#initialize' do
    let(:bidding) { create(:bidding, kind: :lot) }
    let(:lot_1) { bidding.lots.first }
    let(:proposal) do
      create(:proposal, bidding: bidding, lot: lot_1,
                        status: :failure, price_total: 6000)
    end

    subject { described_class.new(params) }

    it { expect(subject.bidding).to eq bidding }
    it { expect(subject.proposal).to eq proposal }
  end

  describe '.call!' do
    let!(:bidding) { create(:bidding, kind: :lot) }
    let!(:lot_1) { bidding.lots.first }
    let!(:lot_2) { create(:lot, bidding: bidding) }
    let!(:lot_3) { create(:lot, bidding: bidding) }
    let!(:proposal_a_lot_1) do
      create(:proposal, bidding: bidding, lot: lot_1, status: :sent,
                        price_total: 5001, sent_updated_at: DateTime.now)
    end
    let!(:proposal_b_lot_1) do
      create(:proposal, bidding: bidding, lot: lot_1, status: :sent,
                        price_total: 5000, sent_updated_at: DateTime.now+1.day)
    end
    let!(:proposal)         do
      create(:proposal, bidding: bidding, lot: lot_1, status: :failure,
                        price_total: 6000)
    end
    let!(:proposal_a_lot_2) do
      create(:proposal, bidding: bidding, lot: lot_2, status: :triage,
                        price_total: 1001, sent_updated_at: DateTime.now)
    end
    let!(:proposal_b_lot_2) do
      create(:proposal, bidding: bidding, lot: lot_2, status: :accepted,
                        price_total: 1000, sent_updated_at: DateTime.now+1.day)
    end
    let!(:proposal_c_lot_2) do
      create(:proposal, bidding: bidding, lot: lot_2, status: :triage,
                        price_total: 2000)
    end
    let!(:proposal_a_lot_3) do
      create(:proposal, bidding: bidding, lot: lot_3, status: :accepted,
                        price_total: 999, sent_updated_at: DateTime.now)
    end
    let!(:proposal_b_lot_3) do
      create(:proposal, bidding: bidding, lot: lot_3, status: :triage,
                        price_total: 1000, sent_updated_at: DateTime.now+1.day)
    end
    let!(:proposal_c_lot_3) do
      create(:proposal, bidding: bidding, lot: lot_3, status: :triage,
                        price_total: 2000)
    end

    subject { described_class.call!(params) }

    context 'when return success' do
      before do
        subject
        proposal_a_lot_1.reload
        proposal_b_lot_1.reload
        proposal.reload
        proposal_a_lot_2.reload
        proposal_b_lot_2.reload
        proposal_c_lot_2.reload
        lot_1.reload
      end

      it { expect(proposal_a_lot_1.sent?).to be_truthy }
      it { expect(proposal_b_lot_1.triage?).to be_truthy }
      it { expect(proposal.failure?).to be_truthy }
      it { expect(proposal_a_lot_2.sent?).to be_falsy }
      it { expect(proposal_b_lot_2.sent?).to be_falsy }
      it { expect(proposal_c_lot_2.sent?).to be_falsy }

      it { expect(lot_1.triage?).to be_truthy }
      it { expect(lot_2.draft?).to be_truthy }
      it { expect(lot_3.draft?).to be_truthy }
    end

    context 'when return RecordInvalid error' do
      before do
        allow_any_instance_of(described_class).
          to receive(:change_proposals_statuses_to_sent!).
          and_raise(ActiveRecord::RecordInvalid)
      end

      it { expect { subject }.to raise_error(ActiveRecord::RecordInvalid) }
    end
  end
end
