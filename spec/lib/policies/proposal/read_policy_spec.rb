require 'rails_helper'

RSpec.describe Policies::Proposal::ReadPolicy do
  let(:user) { create(:supplier) }
  let(:provider) { user.provider }
  let(:bidding) { create(:bidding) }
  let(:proposal) { create(:proposal, bidding: bidding, provider: provider) }

  describe '#initialize' do
    subject { described_class.new(proposal, user) }

    it { expect(subject.proposal).to eq proposal }
    it { expect(subject.supplier).to eq user }
  end

  describe '.allowed?' do
    context 'when is permitted' do
      subject { described_class.allowed?(proposal, user) }

      context 'and the bidding finnished' do
        let(:bidding) { create(:bidding, status: :finnished) }

        it { is_expected.to be_truthy }
      end

      context 'and the bidding is under review' do
        context 'and unrestricted and proposal supplier is owner' do
          let(:bidding) do
            create(:bidding, status: :under_review, modality: :unrestricted)
          end

          it { is_expected.to be_truthy }
        end
      end
    end

    context 'when is not permitted' do
      let(:another_user) { create(:supplier) }

      subject { described_class.allowed?(proposal, another_user) }

      context 'and the bidding is not finnished or under review' do
        it { is_expected.to be_falsey }
      end

      context 'and the bidding is under review and is not unrestricted' do
        let(:bidding) do
          create(:bidding, build_invite: true, status: :under_review, modality: :open_invite)
        end

        it { is_expected.to be_falsey }
      end
    end
  end
end
