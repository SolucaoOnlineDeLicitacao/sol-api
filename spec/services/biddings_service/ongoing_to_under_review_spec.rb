require 'rails_helper'

RSpec.describe BiddingsService::OngoingToUnderReview, type: :service do
  let!(:not_eligible_bidding_1) { create(:bidding, status: :waiting) }
  let!(:not_eligible_bidding_2) { create(:bidding, status: :approved) }
  let!(:not_eligible_bidding_3) { create(:bidding, status: :ongoing) }
  let(:status_update_service) { BiddingsService::UnderReview }

  describe '.call' do
    context 'when have ongoing biddings' do
      let!(:eligible_bidding_1) do
        create(:bidding, status: :ongoing, closing_date: Date.current)
      end
      let!(:eligible_bidding_2) do
        create(:bidding, status: :ongoing, closing_date: Date.current)
      end

      before do
        allow(status_update_service).
          to receive(:call!).with(bidding: eligible_bidding_1).and_return(true)
        allow(status_update_service).
          to receive(:call!).with(bidding: eligible_bidding_2).and_return(true)

        described_class.call
      end

      it { is_expected.to be_truthy }
      it do
        expect(status_update_service).
          to have_received(:call!).with(bidding: eligible_bidding_1)
      end
      it do
        expect(status_update_service).
          to have_received(:call!).with(bidding: eligible_bidding_2)
      end
      it do
        expect(status_update_service).
          not_to have_received(:call!).with(bidding: not_eligible_bidding_1)
      end
      it do
        expect(status_update_service).
          not_to have_received(:call!).with(bidding: not_eligible_bidding_2)
      end
      it do
        expect(status_update_service).
          not_to have_received(:call!).with(bidding: not_eligible_bidding_3)
      end
    end

    context 'when have not ongoing biddings' do
      before do
        allow(status_update_service).to receive(:call!).and_call_original

        described_class.call
      end

      it { expect(status_update_service).not_to have_received(:call!) }
    end
  end
end
