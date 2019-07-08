require 'rails_helper'

RSpec.describe ProposalService::Create, type: :service do
  let(:user) { create(:supplier) }
  let(:provider) { user.provider }
  let(:bidding) { create(:bidding) }
  let(:proposal) { build(:proposal) }
  let(:params) { { proposal: proposal, user: user, provider: provider, bidding: bidding } }

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.proposal).to eq(proposal) }
    it { expect(subject.user).to eq(user) }
    it { expect(subject.provider).to eq(provider) }
    it { expect(subject.bidding).to eq(bidding) }
  end

  describe '.call' do
    let(:response) { double('api_response', success?: blockchain_response) }

    subject { described_class.call(params) }

    context 'when it runs successfully' do
      context 'and the lot proposal is successfully created' do
        context 'and status is not reported' do
          let(:blockchain_response) { true }
          let(:lot_proposal_ids) do
            proposal.lot_proposals.map(&:supplier_id).uniq
          end

          before do
            allow(Blockchain::Proposal::Create).
              to receive(:call).with(proposal).and_return(response)
          end

          it { is_expected.to be_truthy }
          it { expect { subject }.to change { Proposal.count }.by(1) }
          it { expect { subject }.to change { proposal.bidding }.to(bidding) }
          it { expect { subject }.to change { proposal.provider }.to(provider) }
          it { expect { subject }.to change { proposal.status }.from('draft').to('sent') }

          describe 'when validating lot supplier with user' do
            before { subject }

             it { expect(lot_proposal_ids).to eq [user.id] }
          end

          describe 'when validating blockchain call' do
            before { subject }

             it { expect(Blockchain::Proposal::Create).to have_received(:call).with(proposal) }
          end
        end

        context 'and status is reported' do
          let(:blockchain_response) { true }
          let(:lot_proposal_ids) do
            proposal.lot_proposals.map(&:supplier_id).uniq
          end

          before do
            allow(Blockchain::Proposal::Create).
              to receive(:call).with(proposal).and_return(response)
          end

          subject do
            described_class.call(proposal: proposal,
                                 user: user,
                                 provider: provider,
                                 bidding: bidding,
                                 status: :draft)
          end

          it { is_expected.to be_truthy }
          it { expect { subject }.to change { Proposal.count }.by(1) }
          it { expect { subject }.to change { proposal.bidding }.to(bidding) }
          it { expect { subject }.to change { proposal.provider }.to(provider) }
          it { expect { subject }.not_to change { proposal.status } }

          describe 'when validating lot supplier with user' do
            before { subject }

             it { expect(lot_proposal_ids).to eq [user.id] }
          end

          describe 'when validating blockchain call' do
            before { subject }

             it { expect(Blockchain::Proposal::Create).not_to have_received(:call).with(proposal) }
          end
        end
      end
    end

    context 'when it runs with failures' do
      context 'and the proposal is invalid' do
        before do
          allow(proposal).
            to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
        end

        it { is_expected.to be_falsey }
        it { expect { subject }.to change { Proposal.count }.by(0) }
      end

      context 'and the blockchain call has errors' do
        let(:blockchain_response) { false }

        before do
          allow(Blockchain::Proposal::Create).
            to receive(:call).with(proposal).and_return(response)
        end

        it { is_expected.to be_falsey }
        it { expect { subject }.to change { Proposal.count }.by(0) }

        describe 'when validating blockchain call' do
          before { subject }

           it { expect(Blockchain::Proposal::Create).to have_received(:call).with(proposal) }
        end
      end
    end
  end
end
