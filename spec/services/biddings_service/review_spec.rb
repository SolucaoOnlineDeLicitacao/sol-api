require 'rails_helper'

RSpec.describe BiddingsService::Review, type: :service do
  let(:bidding) { create(:bidding, status: :waiting) }
  let(:service) { described_class.new(bidding: bidding) }
  let!(:provider) { create(:provider) }

  describe 'initialization' do
    it { expect(service.bidding).to eq bidding }
  end

  describe 'call' do
    let(:api_response) { double('api_response', success?: true) }
    let(:worker) { Bidding::Minute::PdfGenerateWorker }

    before { Proposal.skip_callback(:commit, :after, :update_price_total) }
    after { Proposal.set_callback(:commit, :after, :update_price_total) }

    context 'when not global' do
      let!(:bidding) { create(:bidding, kind: :lot) }
      let!(:lot_1) { bidding.lots.first }
      let!(:lot_2) { create(:lot, bidding: bidding) }
      let!(:lot_3) { create(:lot, bidding: bidding) }
      let!(:lot_4) { create(:lot, bidding: bidding) }

      context 'when proposal present' do
        let!(:proposal_abandoned_lot_1) do
          create(:proposal, provider: provider, bidding: bidding, lot: lot_1,
            status: :abandoned, price_total: 50, sent_updated_at: DateTime.now - 1.day)
        end

        let!(:proposal_draft_lot_2) do
          create(:proposal, provider: provider, bidding: bidding, lot: lot_2,
            status: :draft, price_total: 50, sent_updated_at: DateTime.now - 1.day)
        end

        let!(:proposal_abandoned_lot_4) do
          create(:proposal, provider: provider, bidding: bidding, lot: lot_4,
            status: :abandoned, price_total: 50, sent_updated_at: DateTime.now - 1.day)
        end

        let!(:proposal_draft_lot_4) do
          create(:proposal, provider: provider, bidding: bidding, lot: lot_4,
            status: :draft, price_total: 50, sent_updated_at: DateTime.now - 1.day)
        end

        let!(:proposal_a_lot_1) do
          create(:proposal, provider: provider, bidding: bidding, lot: lot_1,
            status: :draw, price_total: 5000, sent_updated_at: DateTime.now)
        end

        let!(:proposal_b_lot_1) do
          create(:proposal, provider: provider, bidding: bidding, lot: lot_1,
            status: :draw, price_total: 5000, sent_updated_at: DateTime.now + 1.day)
        end

        let!(:proposal_c_lot_1) do
          create(:proposal, provider: provider, bidding: bidding, lot: lot_1,
            status: :sent, price_total: 6000)
        end


        let!(:proposal_a_lot_2) do
          create(:proposal, provider: provider, bidding: bidding, lot: lot_2,
            status: :draw, price_total: 1000, sent_updated_at: DateTime.now)
        end

        let!(:proposal_b_lot_2) do
          create(:proposal, provider: provider, bidding: bidding, lot: lot_2,
            status: :draw, price_total: 1000, sent_updated_at: DateTime.now + 1.day)
        end

        let!(:proposal_c_lot_2) do
          create(:proposal, provider: provider, bidding: bidding, lot: lot_2,
            status: :sent, price_total: 2000)
        end

        context "when updated" do
          context 'and all lots are desert' do
            before do
              allow(Blockchain::Bidding::Update).to receive(:call).with(bidding) { api_response }
              allow(BiddingsService::Clone).to receive(:call!).with(bidding: bidding).and_return(true)

              [proposal_a_lot_1, proposal_b_lot_1, proposal_c_lot_1].map(&:destroy!)
              [proposal_a_lot_2, proposal_b_lot_2, proposal_c_lot_2].map(&:destroy!)
              service.call
            end

            it { expect(lot_1.reload).to be_desert }
            it { expect(lot_2.reload).to be_desert }
            it { expect(lot_3.reload).to be_desert }
            it { expect(lot_4.reload).to be_desert }
            it { expect(bidding.reload).to be_desert }
            it { expect(Blockchain::Bidding::Update).to have_received(:call).with(bidding) }
            it { expect(BiddingsService::Clone).to have_received(:call!).with(bidding: bidding) }
            it { expect(worker.jobs.size).to eq(1) }
          end

          context 'and all lot are not desert' do
            before do
              allow(Blockchain::Bidding::Update).to receive(:call).with(bidding) { api_response }
              allow(Notifications::Biddings::UnderReview).to receive(:call).with(bidding).and_call_original

              service.call
            end

            it { expect(lot_1.reload).to be_triage }
            it { expect(lot_2.reload).to be_triage }
            it { expect(lot_3.reload).to be_desert }
            it { expect(lot_4.reload).to be_desert }

            it { expect(proposal_abandoned_lot_1.reload).to be_abandoned }
            it { expect(proposal_draft_lot_2.reload).to be_draft }
            it { expect(proposal_abandoned_lot_4.reload).to be_abandoned }
            it { expect(proposal_draft_lot_4.reload).to be_draft }

            it { expect(proposal_a_lot_1.reload).to be_triage }
            it { expect(proposal_b_lot_1.reload).to be_sent }
            it { expect(proposal_c_lot_1.reload).to be_sent }

            it { expect(proposal_a_lot_2.reload).to be_triage }
            it { expect(proposal_b_lot_2.reload).to be_sent }
            it { expect(proposal_c_lot_2.reload).to be_sent }

            it { expect(bidding.reload).to be_under_review }
            it { expect(Blockchain::Bidding::Update).to have_received(:call).with(bidding) }
            it { expect(Notifications::Biddings::UnderReview).to have_received(:call).with(bidding) }
          end
        end

        context 'when not updated' do
          before do
            allow(lot_1).to receive(:triage!) { raise ActiveRecord::RecordInvalid }
          end

          let(:service_return) { service.call }

          it { expect(lot_1.reload).not_to be_triage }
          it { expect(lot_2.reload).not_to be_triage }
          # this one checks proposals missing
          it { expect(lot_3.reload).not_to be_desert }
          it { expect(lot_4.reload).not_to be_desert }

          it { expect(proposal_abandoned_lot_1.reload).to be_abandoned }
          it { expect(proposal_draft_lot_2.reload).to be_draft }
          it { expect(proposal_abandoned_lot_4.reload).to be_abandoned }
          it { expect(proposal_draft_lot_4.reload).to be_draft }

          it { expect(proposal_a_lot_1.reload).to be_draw }
          it { expect(proposal_b_lot_1.reload).to be_draw }
          it { expect(proposal_c_lot_1.reload).to be_sent }

          it { expect(proposal_a_lot_2.reload).to be_draw }
          it { expect(proposal_b_lot_2.reload).to be_draw }
          it { expect(proposal_c_lot_2.reload).to be_sent }

          it { expect(bidding.reload).not_to be_under_review }
        end
      end
    end

    context 'when global' do
      let!(:bidding) { create(:bidding, kind: :global) }
      let!(:lot) { bidding.lots.first }

      context 'when proposal present' do
        let!(:proposal) do
          create(:proposal, provider: provider, price_total: 1_000,
            status: :sent, bidding: bidding)
        end

        let!(:proposal_2) do
          create(:proposal, provider: provider, price_total: 500,
            status: :draft, bidding: bidding)
        end

        let!(:proposal_3) do
          create(:proposal, provider: provider, price_total: 1_500,
            status: :draw, bidding: bidding)
        end

        let!(:proposal_abandoned) do
          create(:proposal, provider: provider, price_total: 50,
            status: :abandoned, bidding: bidding)
        end

        let!(:proposal_draft) do
          create(:proposal, provider: provider, price_total: 15,
            status: :draft, bidding: bidding)
        end


        context "when updated" do
          context 'when only draft or abandoned proposals' do
            before do
              allow(Blockchain::Bidding::Update).to receive(:call).with(bidding) { api_response }
              allow(BiddingsService::Clone).to receive(:call!).with(bidding: bidding).and_return(true)

              [proposal, proposal_2, proposal_3].map(&:destroy!)
              service.call
            end

            it { expect(lot).to be_desert }

            it { expect(proposal_abandoned.reload).to be_abandoned }
            it { expect(proposal_draft.reload).to be_draft }

            it { expect(bidding.reload).to be_desert }

            it { expect(Blockchain::Bidding::Update).to have_received(:call).with(bidding) }
            it { expect(BiddingsService::Clone).to have_received(:call!).with(bidding: bidding) }
            it { expect(worker.jobs.size).to eq(1) }
          end

          context 'when not only draft or abandoned proposals' do
            before do
              allow(Blockchain::Bidding::Update).to receive(:call).with(bidding) { api_response }
              allow(Notifications::Biddings::UnderReview).to receive(:call).with(bidding).and_call_original

              service.call
            end

            it { expect(lot).to be_triage }

            it { expect(proposal.reload).to be_triage }
            it { expect(proposal_2.reload).to be_draft }
            it { expect(proposal_3.reload).to be_sent }

            it { expect(bidding.reload).to be_under_review }

            it { expect(Blockchain::Bidding::Update).to have_received(:call).with(bidding) }
            it { expect(Notifications::Biddings::UnderReview).to have_received(:call).with(bidding) }
          end
        end

        context 'when not updated' do
          before do
            allow(lot).to receive(:triage!) { raise ActiveRecord::RecordInvalid }
          end

          let(:service_return) { service.call }

          it { expect(lot).not_to be_triage }

          it { expect(proposal.reload).to be_sent }
          it { expect(proposal_2.reload).to be_draft }
          it { expect(proposal_3.reload).to be_draw }

          it { expect(bidding.reload).not_to be_under_review }
        end
      end

      context 'when proposals missing' do
        before do
          allow_any_instance_of(Lot).to receive(:proposals) { Proposal.none }
          service.call
        end

        it { expect(lot).to be_desert }
        it { expect(bidding).to be_desert }
      end
    end
  end
end
