require 'rails_helper'

RSpec.describe ProposalService::Admin::LotProposal::Accept, type: :service do
  let(:bidding) { create(:bidding) }
  let(:lots) { bidding.lots }
  let(:lot) { lots.first }
  let(:proposal) { create(:proposal, status: :sent) }
  let(:lot_proposal) { create(:lot_proposal, lot: lot, proposal: proposal) }
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
      allow(Notifications::Proposals::Lots::Accepted).
        to receive(:call).with(proposal, lot).and_return(true)
    end

    subject { described_class.call(params) }

    context 'when success' do
      before do
        subject
        lot_proposal.reload
      end

      it { is_expected.to be_truthy }
      it { expect(lot_proposal.proposal.accepted?).to be_truthy }
      it { expect(lot_proposal.lot.accepted?).to be_truthy }
      it do
        expect(Blockchain::Proposal::Update).
          to have_received(:call).with(proposal)
      end
      it do
        expect(Notifications::Proposals::Lots::Accepted).
          to have_received(:call).with(proposal, lot)
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
        it { expect(lot_proposal.proposal.accepted?).to be_falsey }
        it { expect(lot_proposal.lot.accepted?).to be_falsey }
        it do
          expect(Blockchain::Proposal::Update).
            not_to have_received(:call).with(proposal)
        end
        it do
          expect(Notifications::Proposals::Lots::Accepted).
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
        it { expect(lot_proposal.proposal.accepted?).to be_falsey }
        it { expect(lot_proposal.lot.accepted?).to be_falsey }
        it do
          expect(Notifications::Proposals::Lots::Accepted).
            not_to have_received(:call).with(proposal, lot)
        end
      end
    end
  end
end
