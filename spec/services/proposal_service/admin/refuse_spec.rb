require 'rails_helper'

RSpec.describe ProposalService::Admin::Refuse, type: :service do
  let(:bidding) { create(:bidding) }
  let(:lots) { bidding.lots }
  let(:lot) { lots.first }
  let(:status) { :sent }
  let(:proposal) { create(:proposal, lot: lot, bidding: bidding, status: status) }
  let(:proposal2) { create(:proposal, lot: lot, bidding: bidding, status: status) }
  let!(:proposal3) { create(:proposal, lot: lot, bidding: bidding, status: status) }
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
      allow(Notifications::Proposals::Refused).
        to receive(:call).with(proposal).and_return(true)
    end

    subject { described_class.call(params) }

    context 'when success' do
      context 'and not all refused or abandoned' do
        before do
          subject
          proposal.reload
        end

        it { is_expected.to be_truthy }
        it { expect(proposal.refused?).to be_truthy }
        it { expect(proposal.lots.map(&:failure?).all?).to be_falsey }
        it do
          expect(Blockchain::Proposal::Update).
            to have_received(:call).with(proposal)
        end
        it do
          expect(Notifications::Proposals::Refused).
            to have_received(:call).with(proposal)
        end
      end

      context 'and only one refused' do
        before do
          proposal2.refused!
          subject
          proposal.reload
        end

        it { is_expected.to be_truthy }
        it { expect(proposal.refused?).to be_truthy }
        it { expect(proposal.lots.map(&:failure?).all?).to be_falsey }
        it do
          expect(Blockchain::Proposal::Update).
            to have_received(:call).with(proposal)
        end
        it do
          expect(Notifications::Proposals::Refused).
            to have_received(:call).with(proposal)
        end
      end

      context 'and only one draft' do
        let(:status) { :refused }

        before do
          proposal2.draft!
          subject
          proposal.reload
        end

        it { is_expected.to be_truthy }
        it { expect(proposal.refused?).to be_truthy }
        it { expect(proposal.lots.map(&:failure?).all?).to be_truthy }
        it do
          expect(Blockchain::Proposal::Update).
            to have_received(:call).with(proposal)
        end
        it do
          expect(Notifications::Proposals::Refused).
            to have_received(:call).with(proposal)
        end
      end

      context 'and all refused or abandoned' do
        let(:status) { :refused }

        before do
          proposal.abandoned!
          subject
          proposal.reload
        end

        it { is_expected.to be_truthy }
        it { expect(proposal.refused?).to be_truthy }
        it { expect(proposal.lots.map(&:failure?).all?).to be_truthy }
        it do
          expect(Blockchain::Proposal::Update).
            to have_received(:call).with(proposal)
        end
        it do
          expect(Notifications::Proposals::Refused).
            to have_received(:call).with(proposal)
        end
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
        it { expect(proposal.refused?).to be_falsey }
        it { expect(proposal.lots.map(&:failure?).all?).to be_falsey }
        it do
          expect(Blockchain::Proposal::Update).
            not_to have_received(:call).with(proposal)
        end
        it do
          expect(Notifications::Proposals::Refused).
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
        it { expect(proposal.refused?).to be_falsey }
        it { expect(proposal.lots.map(&:failure?).all?).to be_falsey }
        it do
          expect(Notifications::Proposals::Refused).
            not_to have_received(:call).with(proposal)
        end
      end
    end
  end
end
