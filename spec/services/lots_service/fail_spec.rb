require 'rails_helper'

RSpec.describe LotsService::Fail, type: :service do
  let(:covenant) { create(:covenant) }
  let(:user) { create(:admin) }
  let(:lots) { create_list(:lot, 2, status: :accepted) }
  let(:bidding) do
    create(:bidding, covenant: covenant, build_lot: false, lots: lots)
  end
  let(:lot) { lots.first }
  let(:proposal) do
    create(:proposal, status: proposal_status, build_lot_proposal: false,
                      lot_proposals: [lot_proposal], price_total: 100)
  end
  let(:lot_proposal) { create(:lot_proposal, lot: lot) }
  let(:proposal_status) { :coop_accepted }
  let(:comment) { 'a comment' }
  let(:params) do
    { lot_proposal: lot_proposal, creator: user, comment: comment }
  end
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
    allow(Notifications::Proposals::Lots::Fail).
      to receive(:call).with(proposal, lot, anything).and_return(true)
  end

  after { Proposal.set_callback(:commit, :after, :update_price_total) }

  describe '#initialize' do
    subject { described_class.new(params) }

    it { expect(subject.lot_proposal).to eq lot_proposal }
    it { expect(subject.creator).to eq user }
    it { expect(subject.comment).to eq comment }
  end

  describe '.call' do
    let(:status) do
      lot&.proposals&.where.not(status: [:draft, :abandoned])&.map(&:status)
    end
    let(:lower) { lot&.proposals&.lower }

    subject { described_class.call(params) }

    context 'when success' do
      before { subject }

      context 'and coop_accepted' do
        it { is_expected.to be_truthy }
        it { expect(status).to match_array ['triage'] }
        it { expect(lower.status).to eq 'triage' }
        it { expect(lot.reload.triage?).to be_truthy }
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
          expect(Notifications::Proposals::Lots::Fail).
            to have_received(:call).with(proposal, lot, anything)
        end
      end

      context 'and coop_refused' do
        let(:proposal_status) { :coop_refused }

        it { is_expected.to be_truthy }
        it { expect(status).to match_array ['triage'] }
        it { expect(lower.status).to eq 'triage' }
        it { expect(lot.reload.triage?).to be_truthy }
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
          expect(Notifications::Proposals::Lots::Fail).
            to have_received(:call).with(proposal, lot, anything)
        end
      end

      context 'and have 2 proposals' do
        let!(:proposal_2) do
          create(:proposal, status: :sent, build_lot_proposal: false,
                            lot_proposals: [lot_proposal_2], price_total: 200)
        end
        let!(:lot_proposal_2) { create(:lot_proposal, lot: lot) }

        it { is_expected.to be_truthy }
        it { expect(status).to match_array ['sent', 'triage'] }
        it { expect(lower.status).to eq 'triage' }
        it { expect(lot.reload.triage?).to be_truthy }
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
          expect(Notifications::Proposals::Lots::Fail).
            to have_received(:call).with(proposal, lot, anything)
        end
      end
    end

    context 'when error' do
      context 'and RecordInvalid' do
        before do
          allow(lot).to receive(:save!) { raise ActiveRecord::RecordInvalid }

          subject
        end

        it { is_expected.to be_falsey }
        it { expect(status).not_to match_array ['triage'] }
        it { expect(lower.status).not_to eq 'triage' }
        it { expect(lot.reload.triage?).to be_falsey }
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
          expect(Notifications::Proposals::Lots::Fail).
            not_to have_received(:call).with(proposal, lot, anything)
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
        it { expect(lot.reload.triage?).to be_falsey }
        it do
          expect(EventServices::Proposal::CancelProposal::Refused).
            not_to have_received(:new).with(event_service_params)
        end
        it { expect(Blockchain::Proposal::Update).not_to have_received(:call) }
        it do
          expect(Notifications::Proposals::Lots::Fail).
            not_to have_received(:call).with(proposal, lot, anything)
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
        it { expect(lot.reload.triage?).to be_falsey }
        it do
          expect(EventServices::Proposal::CancelProposal::Accepted).
            not_to have_received(:new).with(event_service_params)
        end
        it { expect(Blockchain::Proposal::Update).not_to have_received(:call) }
        it do
          expect(Notifications::Proposals::Lots::Fail).
            not_to have_received(:call).with(proposal, lot, anything)
        end
      end

      context 'and BlockchainError' do
        let(:bc_response) { double('bc_response', success?: false) }

        before { subject }

        it { is_expected.to be_falsey }
        it { expect(status).not_to match_array ['triage'] }
        it { expect(lower.status).not_to eq 'triage' }
        it { expect(lot.reload.triage?).to be_falsey }
        it do
          expect(Notifications::Proposals::Lots::Fail).
            not_to have_received(:call).with(proposal, lot, anything)
        end
      end
    end
  end

  describe '.call!' do
    it_behaves_like "Call::WithExceptionsMethods", ActiveRecord::RecordInvalid
  end
end
