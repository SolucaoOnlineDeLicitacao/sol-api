require 'rails_helper'

RSpec.describe BiddingsService::ApprovedToOngoing, type: :service do
  describe '.call' do
    let!(:eligible_bidding_1) do
      create(:bidding, status: :approved, start_date: Date.current)
    end

    let!(:eligible_bidding_2) do
      create(:bidding, status: :approved, start_date: Date.current)
    end

    let!(:not_eligible_bidding_1) { create(:bidding, status: :ongoing) }

    before do
      allow(Bidding).to receive(:approved_and_started_until_today) { [eligible_bidding_1, eligible_bidding_2] }
      allow(BiddingsService::Ongoing).to receive(:call!).with(bidding: eligible_bidding_1)
      allow(BiddingsService::Ongoing).to receive(:call!).with(bidding: eligible_bidding_2)

      described_class.call
    end

    it { expect(BiddingsService::Ongoing).to have_received(:call!).with(bidding: eligible_bidding_1) }
    it { expect(BiddingsService::Ongoing).to have_received(:call!).with(bidding: eligible_bidding_2) }
  end
end
