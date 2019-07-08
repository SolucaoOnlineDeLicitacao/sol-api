require 'rails_helper'

RSpec.describe ProposalService::Triage, type: :service do
  let(:bidding) { create(:bidding) }
  let(:proposal) { create(:proposal, bidding: bidding, status: :sent) }
  let(:params) { { proposal: proposal } }

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.proposal).to eq proposal }
  end

  describe '.call' do
    let(:api_response) { double('api_response', success?: true) }

    before do
      allow(Blockchain::Proposal::Update).
        to receive(:call).with(proposal).and_return(api_response)
    end

    subject { described_class.call(params) }

    context 'when success' do
      before do
        subject
        proposal.reload
      end

      it { is_expected.to be_truthy }
      it { expect(proposal.triage?).to be_truthy }
      it do
        expect(Blockchain::Proposal::Update).
          to have_received(:call).with(proposal)
      end
    end

    context 'when error' do
      context 'and proposal has errors' do
        before do
          allow(proposal).
            to receive(:save!).and_raise(ActiveRecord::RecordInvalid)

          subject
          proposal.reload
        end

        it { is_expected.to be_falsey }
        it { expect(proposal.triage?).to be_falsey }
        it do
          expect(Blockchain::Proposal::Update).
            not_to have_received(:call).with(proposal)
        end
      end

      context 'and blockchain has errors' do
        let(:api_response) { double('api_response', success?: false) }

        before do
          subject
          proposal.reload
        end

        it { is_expected.to be_falsey }
        it { expect(proposal.triage?).to be_falsey }
      end
    end
  end

  describe '.call!' do
    it_behaves_like "Call::WithExceptionsMethods", ActiveRecord::RecordInvalid
  end
end
