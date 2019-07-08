require 'rails_helper'

RSpec.describe Policies::Bidding::InvitePolicy, type: :model do

  let(:covenant) { create(:covenant) }
  let!(:user) { create(:supplier) }
  let!(:provider) { user.provider }

  let(:bidding) { create(:bidding) }

  describe '#initialize' do
    subject { Policies::Bidding::InvitePolicy.new(bidding, provider) }

    it { expect(subject.bidding).to eq bidding }
    it { expect(subject.invites).to eq bidding.invites }
    it { expect(subject.provider).to eq provider }
  end

  describe '#allowed?' do
    context 'permitted' do
      let!(:invite) { bidding.invites.create(provider: provider) }

      context 'unrestricted' do
        subject { Policies::Bidding::InvitePolicy.new(bidding, provider) }

        it { expect(subject.allowed?).to be_truthy }
      end

      context 'when approved invite' do
        before { bidding.update_attributes(modality: :open_invite) }

        subject { Policies::Bidding::InvitePolicy.new(bidding, provider) }

        it { expect(subject.allowed?).to be_truthy }
      end
    end

    context 'not permitted' do
      before { bidding.update_columns(modality: :open_invite) }

      context 'without invites' do
        before { bidding.invites.where(provider: provider).destroy_all }

        subject { Policies::Bidding::InvitePolicy.new(bidding.reload, provider) }

        it { expect(subject.allowed?).to be_falsy }
      end


      context 'with pending invite' do
        before { bidding.invites.create(provider: provider, status: :pending) }


        subject { Policies::Bidding::InvitePolicy.new(bidding, provider) }

        it { expect(subject.allowed?).to be_falsy }
      end

      context 'with reproved invite' do
        before { bidding.invites.create(provider: provider, status: :reproved) }

        subject { Policies::Bidding::InvitePolicy.new(bidding, provider) }

        it { expect(subject.allowed?).to be_falsy }
      end
    end
  end

  describe '#pending?' do
    subject { Policies::Bidding::InvitePolicy.new(bidding, provider) }

    context 'when only not allowed?' do
      before { allow(subject).to receive(:allowed?) { false } }

      it { expect(subject.pending?).to be_falsy }
    end

    context 'when only provider_pending' do
      before do
        allow(subject).to receive(:allowed?) { true }
        bidding.invites.create(provider: provider, status: :approved)
        bidding.invites.create(provider: provider, status: :reproved)
      end

      it { expect(subject.pending?).to be_falsy }

    end

    context 'when not allowed and provider_pending' do
      before do
        allow(subject).to receive(:allowed?) { false }
        bidding.invites.create(provider: provider, status: :pending)
      end

      subject { Policies::Bidding::InvitePolicy.new(bidding.reload, provider) }

      it { expect(subject.pending?).to be_truthy }
    end
  end

end
