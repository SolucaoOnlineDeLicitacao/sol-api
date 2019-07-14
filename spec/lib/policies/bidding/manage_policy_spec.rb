require 'rails_helper'

RSpec.describe Policies::Bidding::ManagePolicy, type: :model do
  let(:covenant) { create(:covenant) }
  let!(:user) { create(:supplier) }
  let!(:provider) { Provider.find(user.provider_id) }

  subject { Policies::Bidding::ManagePolicy.new(bidding, provider) }

  describe '#initialize' do
    let(:bidding) { create(:bidding) }

    it { expect(subject.bidding).to eq bidding }
    it { expect(subject.provider).to eq provider }
  end

  describe '#allowed?' do
    let(:expected_return) { Bidding.all }

    describe 'default scope' do
      let(:bidding) { create(:bidding) }

      before do
        allow(Bidding).to receive(:by_provider).with(provider) { expected_return }
        allow(expected_return).to receive(:find_by).with(bidding) { Bidding.all }

        subject.allowed?
      end

      it { expect(Bidding).to have_received(:by_provider).with(provider) }
      it { expect(expected_return).to have_received(:find_by).with(bidding) }
    end

    describe 'return value' do
      let(:bidding) { }

      before do
        allow(Bidding).to receive(:by_provider).with(provider) { expected_return }
        allow(expected_return).to receive(:find_by).with(bidding) { Bidding.all }
      end

      context 'when any' do
        let!(:bidding) { create(:bidding) }

        it { expect(subject.allowed?).to be_truthy }
      end

      context 'when empty' do
        it { expect(subject.allowed?).to be_falsey }
      end
    end
  end
end
