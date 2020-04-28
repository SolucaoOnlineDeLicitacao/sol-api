require 'rails_helper'

RSpec.describe ProposalService::LotProposal::Destroy, type: :service do
  describe '.call' do
    let(:response_deleted) { double('api_response', success?: blockchain_response_delete) }
    let(:blockchain_response_delete) { true }
    let(:response_update) { double('api_response', success?: blockchain_response_update) }
    let(:blockchain_response_update) { true }
    let(:proposal) { create(:proposal, status: :sent) }
    let(:lot_proposal) { proposal.lot_proposals.first }

    before do
      allow(Blockchain::Proposal::Delete).
        to receive(:call).with(proposal).and_return(response_deleted)
      allow(Blockchain::Proposal::Update).
        to receive(:call).with(proposal).and_return(response_update)
    end

    subject { described_class.call(lot_proposal: lot_proposal) }

    context 'when it runs successfully' do
      context 'and proposal has not other lots' do
        context 'and the modality is not closed invite' do
          it { is_expected.to be_truthy }

          describe 'when the proposal and lot proposal are destroyed' do
            before { subject }

            it { expect { proposal.reload }.to raise_error(ActiveRecord::RecordNotFound) }
            it { expect { lot_proposal.reload }.to raise_error(ActiveRecord::RecordNotFound) }

            describe 'and validating blockchain call' do
              it { expect(Blockchain::Proposal::Delete).to have_received(:call).with(proposal) }
              it { expect(Blockchain::Proposal::Update).not_to have_received(:call).with(proposal) }
            end
          end
        end

        context 'and the modality is closed invite' do
          let(:invite) { create(:invite, status: :approved) }
          let(:bidding) { create(:bidding, modality: :closed_invite, invites: [invite])}

          context 'and the proposal is sent' do
            let(:proposal) { create(:proposal, status: :sent, bidding: bidding) }

            context 'deletes the lot_proposal' do
              before { subject }
              it { expect { lot_proposal.reload }.to raise_error(ActiveRecord::RecordNotFound) }
            end

            it { is_expected.to be_truthy }
            it { expect { subject }.not_to change { proposal.reload } }
            it { expect { subject }.to change { proposal.status }.from('sent').to('abandoned') }

            describe 'and validating blockchain call' do
              before { subject }

              it { expect(Blockchain::Proposal::Update).to have_received(:call).with(proposal) }
              it { expect(Blockchain::Proposal::Delete).not_to have_received(:call).with(proposal) }
            end
          end

          context 'and the proposal isnt sent' do
            let!(:proposal) { create(:proposal, status: :draft, bidding: bidding) }

            before { subject }

            it { expect { proposal.reload }.to raise_error(ActiveRecord::RecordNotFound) }
            it { expect { lot_proposal.reload }.to raise_error(ActiveRecord::RecordNotFound) }

            describe 'and validating blockchain call' do
              before { subject }

              it { expect(Blockchain::Proposal::Update).not_to have_received(:call).with(proposal) }
              it { expect(Blockchain::Proposal::Delete).not_to have_received(:call).with(proposal) }
            end
          end
        end
      end

      context 'and proposal has other lots' do
        let(:lot_proposals) { create_list(:lot_proposal, 2) }
        let(:proposal) do
          create(:proposal, status: :sent, lot_proposals: lot_proposals)
        end

        it { is_expected.to be_truthy }
        it { expect { subject }.to change { LotProposal.count }.by_at_most(1) }
        it { expect { subject }.to change { proposal.status }.from('sent').to('draft') }
      end
    end

    context 'when it runs with failures' do
      context 'and the lot proposal is not destroyed' do
        before do
          allow(lot_proposal).to receive(:destroy!) { raise ActiveRecord::RecordNotDestroyed }
        end

        it { is_expected.to be_falsey }
        it { expect { subject }.not_to change { lot_proposal.reload } }
      end

      context 'and the blockchain call has errors' do
        context 'and blockchain update' do
          let(:invite) { create(:invite, status: :approved) }
          let(:bidding) { create(:bidding, modality: :closed_invite, invites: [invite])}
          let(:proposal) { create(:proposal, status: :sent, bidding: bidding) }
          let(:blockchain_response_update) { false }

          it { is_expected.to be_falsey }
          it { expect { subject }.not_to change { proposal.reload.sent_updated_at } }
        end

        context 'and blockchain delete' do
          let(:blockchain_response_delete) { false }

          it { is_expected.to be_falsey }
          it { expect { subject }.not_to change { proposal.reload.sent_updated_at } }
        end
      end
    end
  end
end
