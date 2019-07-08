require 'rails_helper'

RSpec.describe Policies::Proposal::SendPolicy do
  let(:user) { create(:supplier) }
  let(:provider) { user.provider }
  let(:lot) { create(:lot) }
  let(:proposal) { create(:proposal, bidding: bidding, provider: provider) }
  let(:lot_proposal) do
    create(:lot_proposal, lot: lot, proposal: proposal, supplier: user)
  end
  let(:bidding) { create(:bidding, build_lot: false, lots: [lot]) }

  describe '#initialize' do
    subject { described_class.new(proposal) }

    it { expect(subject.proposal).to eq proposal }
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

    subject { described_class.allowed?(proposal) }

    context 'when is permitted' do
      let(:invite_policy_response) { true }

      context 'and the bidding ongoing' do
        let(:bidding) { create(:bidding, status: :ongoing) }

        it { is_expected.to be_truthy }
      end

      context 'and the bidding draw' do
        let(:bidding) { create(:bidding, status: :draw) }
        let(:proposal) { create(:proposal, bidding: bidding, provider: provider, status: :draw) }

        it { is_expected.to be_truthy }
      end
    end

    context 'when is not permitted' do
      context 'and the bidding is ongoing and the invite policy is not allowed' do
        let(:bidding) { create(:bidding, status: :ongoing) }
        let(:invite_policy_response) { false }

        it { is_expected.to be_falsey }
      end

      context 'and the invite_policy is allowed' do
        let(:invite_policy_response) { true }

        context 'and the bidding is not ongoing and is not draw' do
          it { is_expected.to be_falsey }
        end

        context 'and the bidding is not ongoing and only bidding is draw' do
          let(:bidding) { create(:bidding, status: :draw) }

          it { is_expected.to be_falsey }
        end
      end
    end
  end
end
