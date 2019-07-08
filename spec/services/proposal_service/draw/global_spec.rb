require 'rails_helper'

RSpec.describe ProposalService::Draw::Global, type: :service do
  let(:service) { described_class.new(bidding) }

  describe 'initialization' do
    let(:bidding) { create(:bidding, kind: :global, status: :ongoing) }

    it { expect(service.bidding).to eq bidding }
    it { expect(service.has_draw).to be_falsy }
  end

  describe 'call' do
    let(:status_bidding) { :ongoing } 
    let(:bidding) { create(:bidding, kind: :global, status: status_bidding) }

    before { Proposal.skip_callback(:commit, :after, :update_price_total) }
    after { Proposal.set_callback(:commit, :after, :update_price_total) }

    let(:status_proposal) { :sent } 
    let!(:proposal_a) { create(:proposal, bidding: bidding, status: status_proposal, price_total: 5000) }
    let!(:proposal_b) { create(:proposal, bidding: bidding, status: status_proposal, price_total: 5000) }
    let!(:proposal_c) { create(:proposal, bidding: bidding, status: status_proposal, price_total: 6000) }

    before { service.call }

    describe 'success' do
      it { expect(proposal_a.reload.draw?).to be_truthy }
      it { expect(proposal_b.reload.draw?).to be_truthy }
      it { expect(proposal_c.reload.draw?).to be_falsy }

      it { expect(service.has_draw).to be_truthy }
      it { expect(bidding.reload.draw?).to be_truthy }
    end

    describe 'when bidding are draw' do
      let!(:status_bidding) { :draw }

      it { expect(proposal_a.reload.draw?).to be_falsy }
      it { expect(proposal_b.reload.draw?).to be_falsy }
      it { expect(proposal_c.reload.draw?).to be_falsy }

      it { expect(service.has_draw).to be_falsy }
    end

    describe 'when only proposal one refused' do
      before { proposal_a.refused! }

      it { expect(proposal_a.reload.draw?).to be_falsy }
      it { expect(proposal_c.reload.draw?).to be_falsy }
    end
    
  end
end
