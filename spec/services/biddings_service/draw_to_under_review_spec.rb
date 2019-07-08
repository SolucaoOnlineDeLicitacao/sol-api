require 'rails_helper'

RSpec.describe BiddingsService::DrawToUnderReview, type: :service do
  let!(:not_eligible_bidding_1) { create(:bidding, status: :waiting) }
  let!(:not_eligible_bidding_2) { create(:bidding, status: :approved) }
  let!(:not_eligible_bidding_3) { create(:bidding, status: :draw) }
  let(:status_update_service) { BiddingsService::UnderReview }

  before { Bidding.skip_callback(:validation, :before, :update_draw_at) }

  after { Bidding.set_callback(:validation, :before, :update_draw_at) }

  describe '.call' do
    context 'when have draw biddings' do
      let!(:eligible_bidding_1) do
        create(:bidding, status: :draw, draw_at: Date.current)
      end
      let!(:eligible_bidding_2) do
        create(:bidding, status: :draw, draw_at: Date.current)
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

    context 'when have not draw biddings' do
      before do
        allow(status_update_service).to receive(:call!).and_call_original

        described_class.call
      end

      it { expect(status_update_service).not_to have_received(:call!) }
    end
  end
end
