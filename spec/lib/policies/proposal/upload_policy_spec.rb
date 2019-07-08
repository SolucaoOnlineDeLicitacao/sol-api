require 'rails_helper'

RSpec.describe Policies::Proposal::UploadPolicy do
  let(:user) { create(:supplier) }
  let(:provider) { user.provider }
  let(:bidding) { create(:bidding) }
  let(:proposal_import) do
    create(:proposal_import, bidding: bidding, provider: provider)
  end

  describe '#initialize' do
    subject { described_class.new(proposal_import) }

    it { expect(subject.proposal_import).to eq proposal_import }
  end

  describe '.allowed?' do
    let(:invite_policy) do
      double('invite_policy', allowed?: invite_policy_response)
    end

    before do
      allow(Policies::Bidding::InvitePolicy).
        to receive(:new).
        with(bidding, provider).
        and_return(invite_policy)
    end

    subject { described_class.allowed?(proposal_import) }

    context 'when is permitted' do
      let(:invite_policy_response) { true }
      let(:bidding) { create(:bidding, status: :ongoing) }

      it { is_expected.to be_truthy }
    end

    context 'when is not permitted' do
      context 'and the bidding is ongoing and the invite policy is not allowed' do
        let(:bidding) { create(:bidding, status: :ongoing) }
        let(:invite_policy_response) { false }

        it { is_expected.to be_falsey }
      end

      context 'and the bidding is not ongoing and the invite policy is allowed' do
        let(:invite_policy_response) { true }

        it { is_expected.to be_falsey }
      end
    end
  end
end
