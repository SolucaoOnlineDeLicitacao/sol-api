require 'rails_helper'

RSpec.describe BiddingsService::DrawToUnderReview, type: :service do
  describe '.call' do
    let!(:eligible_bidding_1) do
      create(:bidding, status: :draw, draw_at: Date.current)
    end

    let!(:eligible_bidding_2) do
      create(:bidding, status: :draw, draw_at: Date.current)
    end

    let!(:not_eligible_bidding_1) { create(:bidding, status: :waiting) }

    before do
      allow(Bidding).to receive(:drawed_until_today) { [eligible_bidding_1, eligible_bidding_2] }
      allow(BiddingsService::UnderReview).to receive(:call!).with(bidding: eligible_bidding_1)
      allow(BiddingsService::UnderReview).to receive(:call!).with(bidding: eligible_bidding_2)

      described_class.call
    end

    it { expect(BiddingsService::UnderReview).to have_received(:call!).with(bidding: eligible_bidding_1) }
    it { expect(BiddingsService::UnderReview).to have_received(:call!).with(bidding: eligible_bidding_2) }
  end
end
