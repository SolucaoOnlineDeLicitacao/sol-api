require 'rails_helper'

RSpec.describe ProposalService::Destroy, type: :service do
  describe '.call' do
    let(:response_deleted) { double('api_response', success?: blockchain_response_delete) }
    let(:blockchain_response_delete) { true }
    let(:response_update) { double('api_response', success?: blockchain_response_update) }
    let(:blockchain_response_update) { true }
    let(:proposal) { create(:proposal) }

    before do
      allow(Blockchain::Proposal::Delete).
        to receive(:call).with(proposal).and_return(response_deleted)
      allow(Blockchain::Proposal::Update).
        to receive(:call).with(proposal).and_return(response_update)
    end

    subject { described_class.call(proposal: proposal) }

    context 'when it runs successfully' do
      context 'and the proposal is successfully destroyed' do
        context 'and the modality is not closed invite' do
          describe "service" do
            it { is_expected.to be_truthy }
          end

          describe 'when the proposal is destroyed' do
            before { subject }

            it { expect { proposal.reload }.to raise_error(ActiveRecord::RecordNotFound) }
          end

          describe "blockchain" do
            context "when proposal isnt draft" do
              before { proposal.sent!; proposal.reload; subject }

              it { expect(Blockchain::Proposal::Update).not_to have_received(:call).with(proposal) }
              it { expect(Blockchain::Proposal::Delete).to have_received(:call).with(proposal) }
            end

            context "when proposal is draft" do
              before { subject }

              it { expect(Blockchain::Proposal::Update).not_to have_received(:call).with(proposal) }
              it { expect(Blockchain::Proposal::Delete).not_to have_received(:call).with(proposal) }
            end
          end
        end

        context 'and the modality is closed invite' do
          let(:invite) { create(:invite, status: :approved) }
          let(:bidding) { create(:bidding, modality: :closed_invite, invites: [invite]) }
          let(:proposal) { create(:proposal, bidding: bidding, status: :sent) }

          it { is_expected.to be_truthy }
          it { expect { subject }.not_to change { proposal.reload } }
          it { expect { subject }.to change { proposal.status }.from('sent').to('abandoned') }

          describe "blockchain" do
            context "when proposal isnt draft" do
              before { subject }

              it { expect(Blockchain::Proposal::Update).to have_received(:call).with(proposal) }
              it { expect(Blockchain::Proposal::Delete).not_to have_received(:call).with(proposal) }
            end

            context "when proposal is draft" do
              before { proposal.draft!; proposal.reload; subject }

              it { expect(Blockchain::Proposal::Update).not_to have_received(:call).with(proposal) }
              it { expect(Blockchain::Proposal::Delete).not_to have_received(:call).with(proposal) }
            end
          end
        end
      end
    end

    context 'when it runs with failures' do
      context 'and the proposal is not destroyed' do
        before do
          allow(proposal).to receive(:destroy!).and_raise(ActiveRecord::RecordNotDestroyed)
        end

        it { is_expected.to be_falsey }
        it { expect { subject }.not_to change { proposal.reload } }
      end

      context 'and the blockchain call has errors' do
        let(:invite) { create(:invite, status: :approved) }
        let(:bidding) { create(:bidding, modality: :closed_invite, invites: [invite]) }
        let(:proposal) { create(:proposal, bidding: bidding, status: :sent) }

        context 'and blockchain update' do
          let(:blockchain_response_update) { false }

          before { subject }

          it { is_expected.to be_falsey }
          it { expect { subject }.not_to change { proposal.reload.sent_updated_at } }
          it { expect(Blockchain::Proposal::Update).to have_received(:call).with(proposal) }
          it { expect(Blockchain::Proposal::Delete).not_to have_received(:call).with(proposal) }
        end

        context 'and blockchain delete' do
          let(:blockchain_response_delete) { false }

          before { proposal.triage!; proposal.reload; subject }

          it { is_expected.to be_falsey }
          it { expect { subject }.not_to change { proposal.reload.sent_updated_at } }
          it { expect(Blockchain::Proposal::Update).not_to have_received(:call).with(proposal) }
          it { expect(Blockchain::Proposal::Delete).to have_received(:call).with(proposal) }
        end
      end
    end
  end
end
