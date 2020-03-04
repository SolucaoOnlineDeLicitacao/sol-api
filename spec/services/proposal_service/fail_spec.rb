require 'rails_helper'

RSpec.describe ProposalService::Fail, type: :service do
  let(:covenant) { create(:covenant) }
  let(:user) { create(:admin) }
  let(:lots) { create_list(:lot, 2, status: :accepted) }

  let(:bidding) do
    create(:bidding, covenant: covenant, build_lot: false, lots: lots)
  end

  let(:lot) { lots.first }

  let(:proposal) do
    create(:proposal, bidding: bidding, status: proposal_status,
                      price_total: 100)
  end

  let(:proposal_status) { :coop_accepted }
  let(:lot_proposal) { create(:lot_proposal, lot: lot, proposal: proposal) }
  let(:comment) { 'a comment' }
  let(:params) { { proposal: proposal, creator: user, comment: comment } }

  let(:event_service_params) do
    { proposal: proposal, comment: comment, creator: user }
  end

  let(:accepted_event) do
    create(:event_cancel_proposal_accepted, eventable: proposal, creator: user)
  end

  let(:refused_event) do
    create(:event_cancel_proposal_refused, eventable: proposal, creator: user)
  end

  let(:accepted_event_response) do
    double('event_response', call!: true, event: accepted_event)
  end

  let(:refused_event_response) do
    double('event_response', call!: true, event: refused_event)
  end

  let(:bc_response) { double('bc_response', success?: true) }

  before do
    Proposal.skip_callback(:commit, :after, :update_price_total)

    allow(EventServices::Proposal::CancelProposal::Accepted).
      to receive(:new).with(event_service_params).
      and_return(accepted_event_response)

    allow(EventServices::Proposal::CancelProposal::Refused).
      to receive(:new).with(event_service_params).
      and_return(refused_event_response)

    allow(Blockchain::Proposal::Update).
      to receive(:call).and_return(bc_response)
    allow(Notifications::Proposals::Fail).
      to receive(:call).with(proposal, anything).and_return(true)
  end

  after { Proposal.set_callback(:commit, :after, :update_price_total) }

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.proposal).to eq proposal }
    it { expect(subject.creator).to eq user }
    it { expect(subject.comment).to eq comment }
  end

  describe '.call' do
    let(:status) do
      bidding&.proposals&.not_failure.not_draft_or_abandoned&.map(&:status)
    end
    let(:lower) { bidding&.proposals&.lower }

    subject { described_class.call(params) }

    context 'when success' do

      context 'and coop_accepted' do
        before { subject }

        it { is_expected.to be_truthy }
        it { expect(status).to match_array ['triage'] }
        it { expect(lower.status).to eq 'triage' }
        it { expect(lots.map(&:status)).not_to include('triage') }
        it do
          expect(EventServices::Proposal::CancelProposal::Accepted).
            to have_received(:new).with(event_service_params)
        end
        it do
          expect(EventServices::Proposal::CancelProposal::Refused).
            not_to have_received(:new).with(event_service_params)
        end
        it { expect(Blockchain::Proposal::Update).to have_received(:call) }
        it do
          expect(Notifications::Proposals::Fail).
            to have_received(:call).with(proposal, anything)
        end
      end

      context 'and coop_refused' do
        before { subject }

        let(:proposal_status) { :coop_refused }

        it { is_expected.to be_truthy }
        it { expect(status).to match_array ['triage'] }
        it { expect(lower.status).to eq 'triage' }
        it { expect(lots.map(&:status)).not_to include('triage') }
        it do
          expect(EventServices::Proposal::CancelProposal::Accepted).
            not_to have_received(:new).with(event_service_params)
        end
        it do
          expect(EventServices::Proposal::CancelProposal::Refused).
            to have_received(:new).with(event_service_params)
        end
        it { expect(Blockchain::Proposal::Update).to have_received(:call) }
        it do
          expect(Notifications::Proposals::Fail).
            to have_received(:call).with(proposal, anything)
        end
      end

      context 'and have 2 proposals' do
        before { proposal_2; proposal_3; subject }

        let!(:proposal_2) do
          create(:proposal, bidding: bidding, status: :sent, price_total: 200)
        end

        let!(:lot_proposal_2) do
          create(:lot_proposal, lot: lot, proposal: proposal_2)
        end

        let!(:proposal_3) do
          create(:proposal, bidding: bidding, status: :draft, price_total: 200)
        end

        let!(:lot_proposal_3) do
          create(:lot_proposal, lot: lot, proposal: proposal_3)
        end

        it { is_expected.to be_truthy }
        it { expect(status).to match_array ['sent', 'triage'] }
        it { expect(lower.status).to eq 'triage' }
        it { expect(lots.map(&:status)).not_to include('triage') }
        it { expect(Blockchain::Proposal::Update).to have_received(:call).twice }

        it do
          expect(EventServices::Proposal::CancelProposal::Accepted).
            to have_received(:new).with(event_service_params)
        end

        it do
          expect(EventServices::Proposal::CancelProposal::Refused).
            not_to have_received(:new).with(event_service_params)
        end

        it do
          expect(Notifications::Proposals::Fail).
            to have_received(:call).with(proposal, anything)
        end
      end
    end

    context 'when error' do
      context 'and RecordInvalid' do
        before do
          allow(proposal).
            to receive(:lots) { raise ActiveRecord::RecordInvalid }

          subject
        end

        it { is_expected.to be_falsey }
        it { expect(status).not_to match_array ['triage'] }
        it { expect(lower.status).not_to eq 'triage' }
        it { expect(lots.map(&:status)).not_to include('triage') }
        it do
          expect(EventServices::Proposal::CancelProposal::Accepted).
            not_to have_received(:new).with(event_service_params)
        end
        it do
          expect(EventServices::Proposal::CancelProposal::Refused).
            not_to have_received(:new).with(event_service_params)
        end
        it { expect(Blockchain::Proposal::Update).not_to have_received(:call) }
        it do
          expect(Notifications::Proposals::Fail).
            not_to have_received(:call).with(proposal, anything)
        end
      end

      context 'and event accepted error' do
        before do
          allow(EventServices::Proposal::CancelProposal::Accepted).
            to receive(:new).with(event_service_params).
            and_raise(ActiveRecord::RecordInvalid)

          subject
        end

        it { is_expected.to be_falsey }
        it { expect(status).not_to match_array ['triage'] }
        it { expect(lower.status).not_to eq 'triage' }
        it { expect(lots.map(&:status)).not_to include('triage') }
        it do
          expect(EventServices::Proposal::CancelProposal::Refused).
            not_to have_received(:new).with(event_service_params)
        end
        it { expect(Blockchain::Proposal::Update).not_to have_received(:call) }
        it do
          expect(Notifications::Proposals::Fail).
            not_to have_received(:call).with(proposal, anything)
        end
      end

      context 'and event refused error' do
        let(:proposal_status) { :coop_refused }

        before do
          allow(EventServices::Proposal::CancelProposal::Refused).
            to receive(:new).with(event_service_params).
            and_raise(ActiveRecord::RecordInvalid)

          subject
        end

        it { is_expected.to be_falsey }
        it { expect(status).not_to match_array ['triage'] }
        it { expect(lower.status).not_to eq 'triage' }
        it { expect(lots.map(&:status)).not_to include('triage') }
        it do
          expect(EventServices::Proposal::CancelProposal::Accepted).
            not_to have_received(:new).with(event_service_params)
        end
        it { expect(Blockchain::Proposal::Update).not_to have_received(:call) }
        it do
          expect(Notifications::Proposals::Fail).
            not_to have_received(:call).with(proposal, anything)
        end
      end

      context 'and BlockchainError' do
        let(:bc_response) { double('bc_response', success?: false) }

        before { subject }

        it { is_expected.to be_falsey }
        it { expect(status).not_to match_array ['triage'] }
        it { expect(lower.status).not_to eq 'triage' }
        it { expect(lots.map(&:status)).not_to include('triage') }
        it do
          expect(Notifications::Proposals::Fail).
            not_to have_received(:call).with(proposal, anything)
        end
      end
    end
  end

  describe '.call!' do
    it_behaves_like "Call::WithExceptionsMethods", ActiveRecord::RecordInvalid
  end
end
