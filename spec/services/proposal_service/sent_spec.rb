require 'rails_helper'

RSpec.describe ProposalService::Sent, type: :service do
  describe '.call' do
    let(:proposal) { build(:proposal) }
    let(:blockchain_response_get) { false }
    let(:response_get) { double('api_response', success?: blockchain_response_get) }
    let(:response) { double('api_response', success?: blockchain_response) }

    before { Timecop.freeze(DateTime.current) }

    subject { described_class.call(proposal) }

    after { Timecop.return }

    context 'when it runs successfully' do
      let(:blockchain_response) { true }

      before do
        expect(Blockchain::Proposal::Get).
          to receive(:call).with(proposal).and_return(response_get)
      end

      context 'when try create' do
        let(:blockchain_response_get) { false }

        before do
          expect(Blockchain::Proposal::Create).
            to receive(:call).with(proposal).and_return(response)
        end

        context 'and the proposal is successfully sent' do
          it { is_expected.to be_truthy }
          it { expect { subject }.to change { Proposal.count }.by(1) }
          it { expect { subject }.to change { proposal.status }.from('draft').to('sent') }
          it { expect { subject }.to change { proposal.sent_updated_at }.to be_within(1.second).of(DateTime.current) }
        end
      end

      context 'when try update' do
        let(:blockchain_response_get) { true }

        before do
          expect(Blockchain::Proposal::Update).
            to receive(:call).with(proposal).and_return(response)
        end

        context 'and the proposal is successfully sent' do
          it { is_expected.to be_truthy }
          it { expect { subject }.to change { Proposal.count }.by(1) }
          it { expect { subject }.to change { proposal.status }.from('draft').to('sent') }
          it { expect { subject }.to change { proposal.sent_updated_at }.to be_within(1.second).of(DateTime.current) }
        end
      end
    end

    context 'when it runs with failures' do
      context 'and the proposal is invalid' do
        let(:proposal) { build(:proposal, provider: nil) }

        it { is_expected.to be_falsey }
        it { expect { subject }.to change { Proposal.count }.by(0) }
      end

      context 'and the blockchain call has errors' do
        let(:blockchain_response) { false }

        before do
          expect(Blockchain::Proposal::Get).
            to receive(:call).with(proposal).and_return(response_get)
        end

        context 'when try create' do
          let(:blockchain_response_get) { false }

          before do
            expect(Blockchain::Proposal::Create).
              to receive(:call).with(proposal).and_return(response)
          end

          it { is_expected.to be_falsey }
          it { expect { subject }.to change { Proposal.count }.by(0) }
        end

        context 'when try update' do
          let(:blockchain_response_get) { true }

          before do
            expect(Blockchain::Proposal::Update).
              to receive(:call).with(proposal).and_return(response)
          end

          it { is_expected.to be_falsey }
          it { expect { subject }.to change { Proposal.count }.by(0) }
        end
      end
    end
  end
end
