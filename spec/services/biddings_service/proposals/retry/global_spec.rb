require 'rails_helper'

RSpec.describe BiddingsService::Proposals::Retry::Global, type: :service do
  let(:provider) { create(:provider) }
  let(:classification) { create(:classification, name: 'BENS') }
  let(:bidding) { create(:bidding, status: :finnished, kind: :global, classification: classification) }

  let(:params) { { bidding: bidding } }

  before { Proposal.skip_callback(:commit, :after, :update_price_total) }

  after { Proposal.set_callback(:commit, :after, :update_price_total) }

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.bidding).to eq bidding }
  end

  describe '.call!' do
    subject { described_class.call!(params) }

    context 'when return success' do
      let!(:proposal_2) { create(:proposal, bidding: bidding, provider: provider, price_total: 1000, status: :sent) }
      let!(:proposal_3) { create(:proposal, bidding: bidding, provider: provider, price_total: 300, status: :accepted) }
      let!(:proposal_4) { create(:proposal, bidding: bidding, provider: provider, price_total: 500, status: :refused) }
      let(:lot_2) { proposal_2.lots.first }

      before do
        subject
        proposal_2.reload
        proposal_3.reload
        proposal_4.reload
      end

      it { expect(proposal_2.sent?).to be_truthy }
      it { expect(lot_2.triage?).to be_truthy }
      it { expect(proposal_3.triage?).to be_truthy }
      it { expect(proposal_4.sent?).to be_truthy }
    end

    context 'when return error' do
      let(:proposal) { create(:proposal, bidding: bidding, provider: provider, status: :accepted) }

      context 'when ActiveRecord::RecordInvalid' do
        before do
          allow_any_instance_of(described_class).
            to receive(:change_proposals_statuses_to_sent!).
            and_raise(ActiveRecord::RecordInvalid)
        end

        it { expect { subject }.to raise_error(ActiveRecord::RecordInvalid) }
        it { expect(proposal.lots.map(&:canceled?).uniq).to eq [false] }
      end
    end
  end
end
