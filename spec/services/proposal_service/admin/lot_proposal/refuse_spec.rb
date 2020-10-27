require 'rails_helper'

RSpec.describe ProposalService::Admin::LotProposal::Refuse, type: :service do
  let(:bidding) { create(:bidding) }
  let(:lots) { bidding.lots }
  let(:lot) { lots.first }
  let(:proposal) { create(:proposal, status: proposal_status) }
  let(:lot_proposal) { create(:lot_proposal, lot: lot, proposal: proposal) }
  let(:proposal_status) { :sent }
  let(:params) { { lot_proposal: lot_proposal } }

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.lot_proposal).to eq lot_proposal }
  end

  describe '.call' do
    let(:api_response) { double('api_response', success?: true) }

    before do
      allow(Blockchain::Proposal::Update).
        to receive(:call).with(proposal).and_return(api_response)
      allow(Notifications::Proposals::Lots::Refused).
        to receive(:call).with(proposal, lot).and_return(true)
    end

    subject { described_class.call(params) }

    context 'when success' do
      context 'and not all refused, abandoned or failure' do
        let(:proposal2) { create(:proposal, status: :coop_refused) }
        let!(:lot_proposal2) { create(:lot_proposal, lot: lot, proposal: proposal2) }
        let(:proposal3) { create(:proposal, status: :triage) }
        let!(:lot_proposal3) { create(:lot_proposal, lot: lot, proposal: proposal3) }

        before { subject }

        it { is_expected.to be_truthy }
        it { expect(lot_proposal.proposal.refused?).to be_truthy }
        it { expect(lot_proposal.lot.failure?).to be_falsey }
        it do
          expect(Blockchain::Proposal::Update).
            to have_received(:call).with(proposal)
        end
        it do
          expect(Notifications::Proposals::Lots::Refused).
            to have_received(:call).with(proposal, lot)
        end
      end

      context 'and only one refused' do
        let(:proposal_status) { :refused }

        before { subject }

        it { is_expected.to be_truthy }
        it { expect(lot_proposal.proposal.refused?).to be_truthy }
        it { expect(lot_proposal.lot.failure?).to be_truthy }
        it do
          expect(Blockchain::Proposal::Update).
            to have_received(:call).with(proposal)
        end
        it do
          expect(Notifications::Proposals::Lots::Refused).
            to have_received(:call).with(proposal, lot)
        end
      end

      context 'and only one abandoned' do
        let(:proposal_status) { :abandoned }

        before { subject }

        it { is_expected.to be_truthy }
        it { expect(lot_proposal.proposal.refused?).to be_truthy }
        it { expect(lot_proposal.lot.failure?).to be_truthy }
        it do
          expect(Blockchain::Proposal::Update).
            to have_received(:call).with(proposal)
        end
        it do
          expect(Notifications::Proposals::Lots::Refused).
            to have_received(:call).with(proposal, lot)
        end
      end

      context 'and only one failure' do
        let(:proposal_status) { :failure}

        before { subject }

        it { is_expected.to be_truthy }
        it { expect(lot_proposal.proposal.refused?).to be_truthy }
        it { expect(lot_proposal.lot.failure?).to be_truthy }
        it do
          expect(Blockchain::Proposal::Update).
            to have_received(:call).with(proposal)
        end
        it do
          expect(Notifications::Proposals::Lots::Refused).
            to have_received(:call).with(proposal, lot)
        end
      end

      context 'and all refused, abandoned or failure' do
        let(:proposal2) { create(:proposal, status: :refused) }
        let!(:lot_proposal2) { create(:lot_proposal, lot: lot, proposal: proposal2) }
        let(:proposal3) { create(:proposal, status: :abandoned) }
        let!(:lot_proposal3) { create(:lot_proposal, lot: lot, proposal: proposal3) }
        let(:proposal4) { create(:proposal, status: :failure) }
        let!(:lot_proposal4) { create(:lot_proposal, lot: lot, proposal: proposal4) }

        before { subject }

        it { is_expected.to be_truthy }
        it { expect(lot_proposal.proposal.refused?).to be_truthy }
        it { expect(lot_proposal.lot.failure?).to be_truthy }
        it do
          expect(Blockchain::Proposal::Update).
            to have_received(:call).with(proposal)
        end
        it do
          expect(Notifications::Proposals::Lots::Refused).
            to have_received(:call).with(proposal, lot)
        end
      end
    end

    context 'when error' do
      context 'and proposal has errors' do
        before do
          allow(proposal).
            to receive(:save!).and_raise(ActiveRecord::RecordInvalid)

          subject
          lot_proposal.reload
        end

        it { is_expected.to be_falsey }
        it { expect(lot_proposal.proposal.refused?).to be_falsey }
        it { expect(lot_proposal.lot.failure?).to be_falsey }
        it do
          expect(Blockchain::Proposal::Update).
            not_to have_received(:call).with(proposal)
        end
        it do
          expect(Notifications::Proposals::Lots::Refused).
            not_to have_received(:call).with(proposal, lot)
        end
      end

      context 'and blockchain has errors' do
        let(:api_response) { double('api_response', success?: false) }

        before do
          subject
          lot_proposal.reload
        end

        it { is_expected.to be_falsey }
        it { expect(lot_proposal.proposal.refused?).to be_falsey }
        it { expect(lot_proposal.lot.failure?).to be_falsey }
        it do
          expect(Notifications::Proposals::Lots::Refused).
            not_to have_received(:call).with(proposal, lot)
        end
      end
    end
  end
end
