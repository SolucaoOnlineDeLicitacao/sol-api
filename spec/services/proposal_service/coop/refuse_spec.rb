require 'rails_helper'

RSpec.describe ProposalService::Coop::Refuse, type: :service do
  let(:covenant) { create(:covenant) }
  let(:user) { create(:user) }
  let(:bidding) { create(:bidding, covenant: covenant) }
  let(:lots) { bidding.lots }
  let(:lot) { lots.first }
  let(:proposal) do
    create(:proposal, bidding: bidding, status: :sent, price_total: 100)
  end
  let(:proposal2) do
    create(:proposal, bidding: bidding, status: :sent, price_total: 200)
  end
  let(:lot_proposal) { create(:lot_proposal, lot: lot, proposal: proposal) }
  let(:comment) { 'a comment' }
  let(:params) { { proposal: proposal, creator: user, comment: comment } }
  let(:event_proposal_status) { 'sent' }
  let(:event_service_params) do
    {
      from: event_proposal_status,
      to: 'coop_refused',
      comment: comment,
      creator: user,
      eventable: proposal
    }
  end
  let(:event) do
    create(:event_cancel_proposal_accepted, eventable: proposal, creator: user)
  end
  let(:event_response) do
    double('event_response', save!: true, event: event)
  end
  let(:bc_response) { double('bc_response', success?: true) }

  before do
    Proposal.skip_callback(:commit, :after, :update_price_total)

    allow(Events::ProposalStatusChange).
      to receive(:new).with(event_service_params).and_return(event_response)
    allow(Blockchain::Proposal::Update).
      to receive(:call).and_return(bc_response)
    allow(ProposalService::Triage).
      to receive(:call!).with(proposal: proposal2) { proposal2.triage! }
    allow(Notifications::Proposals::CoopRefused).
      to receive(:call).with(proposal).and_return(true)
  end

  after { Proposal.set_callback(:commit, :after, :update_price_total) }

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.proposal).to eq proposal }
    it { expect(subject.creator).to eq user }
    it { expect(subject.comment).to eq comment }
  end

  describe '.call' do
    subject { described_class.call(params) }

    context 'when success' do
      before { subject }

      it { is_expected.to be_truthy }
      it { expect(proposal.coop_refused?).to be_truthy }
      it { expect(proposal2.triage?).to be_truthy }
      it do
        expect(Events::ProposalStatusChange).
          to have_received(:new).with(event_service_params)
      end
      it { expect(Blockchain::Proposal::Update).to have_received(:call) }
      it do
        expect(ProposalService::Triage).
          to have_received(:call!).with(proposal: proposal2)
      end
      it do
        expect(Notifications::Proposals::CoopRefused).
          to have_received(:call).with(proposal)
      end
    end

    context 'when error' do
      context 'and proposal is not sent or triage' do
        let(:event_proposal_status) { 'draft' }

        before do
          proposal.draft!
          subject
        end

        it { is_expected.to be_falsey }
        it { expect(proposal.coop_refused?).to be_falsey }
        it { expect(proposal2.triage?).to be_falsey }
        it do
          expect(Events::ProposalStatusChange).
            not_to have_received(:new).with(event_service_params)
        end
        it { expect(Blockchain::Proposal::Update).not_to have_received(:call) }
        it do
          expect(ProposalService::Triage).
            not_to have_received(:call!).with(proposal: proposal2)
        end
        it do
          expect(Notifications::Proposals::CoopRefused).
            not_to have_received(:call).with(proposal)
        end
      end

      context 'and event error' do
        before do
          allow(Events::ProposalStatusChange).
            to receive(:new).with(event_service_params).
            and_raise(ActiveRecord::RecordInvalid)

          subject
        end

        it { is_expected.to be_falsey }
        it { expect(proposal.coop_refused?).to be_falsey }
        it { expect(proposal2.triage?).to be_falsey }
        it { expect(Blockchain::Proposal::Update).not_to have_received(:call) }
        it do
          expect(ProposalService::Triage).
            not_to have_received(:call!).with(proposal: proposal2)
        end
        it do
          expect(Notifications::Proposals::CoopRefused).
            not_to have_received(:call).with(proposal)
        end
      end

      context 'and RecordInvalid' do
        before do
          allow(proposal).
            to receive(:save!) { raise ActiveRecord::RecordInvalid }

          subject
          proposal.reload
        end

        it { is_expected.to be_falsey }
        it { expect(proposal.coop_refused?).to be_falsey }
        it { expect(proposal2.triage?).to be_falsey }
        it { expect(Blockchain::Proposal::Update).not_to have_received(:call) }
        it do
          expect(ProposalService::Triage).
            not_to have_received(:call!).with(proposal: proposal2)
        end
        it do
          expect(Notifications::Proposals::CoopRefused).
            not_to have_received(:call).with(proposal)
        end
      end

      context 'and BlockchainError' do
        let(:bc_response) { double('bc_response', success?: false) }

        before do
          subject
          proposal.reload
        end

        it { is_expected.to be_falsey }
        it { expect(proposal.coop_refused?).to be_falsey }
        it { expect(proposal2.triage?).to be_falsey }
        it do
          expect(ProposalService::Triage).
            not_to have_received(:call!).with(proposal: proposal2)
        end
        it do
          expect(Notifications::Proposals::CoopRefused).
            not_to have_received(:call).with(proposal)
        end
      end
    end
  end
end
