require 'rails_helper'

RSpec.describe EventServices::Proposal::CancelProposal::Refused, type: :service do

  let(:user) { create(:admin) }
  let(:bidding) { create(:bidding) }
  let(:proposal) { create(:proposal, bidding: bidding, status: :coop_refused) }
  let(:comment) { 'a comment' }
  let(:params) do
    {
      proposal: proposal,
      comment: comment,
      creator: user
    }
  end

  describe '#initializer' do
    subject { described_class.new(params) }

    it { expect(subject.proposal).to eq proposal }
    it { expect(subject.comment).to eq comment }
    it { expect(subject.creator).to eq user }
  end

  describe '.call!' do
    subject { described_class.call!(params) }

    context 'when return success' do
      before { subject }

      let(:event) { Events::CancelProposalRefused.where(eventable: proposal, creator: user) }

      it { expect(event).to be_present }
      it { expect(subject).to be_truthy }
    end

    context 'when failure' do
      before do
        allow_any_instance_of(Events::CancelProposalRefused).
          to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
      end

      it { expect { subject }.to raise_error(ActiveRecord::RecordInvalid) }
    end
  end
end
