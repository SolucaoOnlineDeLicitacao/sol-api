require 'rails_helper'

RSpec.describe Policies::Bidding::ManagePolicy, type: :model do
  let(:covenant) { create(:covenant) }
  let!(:user) { create(:supplier) }
  let!(:provider) { Provider.find(user.provider_id) }
  let(:bidding) { create(:bidding) }

  subject { Policies::Bidding::ManagePolicy.new(bidding, provider) }

  describe '#initialize' do
    it { expect(subject.bidding).to eq bidding }
    it { expect(subject.provider).to eq provider }
  end

  describe '#allowed?' do
    let(:expected_return) { Bidding.all }
    let(:where_return) { expected_return }

    describe 'default scope' do
      before do
        allow(Bidding).to receive(:by_provider).with(provider) { expected_return }
        allow(expected_return).to receive(:where).with(id: bidding.id) { where_return }

        subject.allowed?
      end

      it { expect(Bidding).to have_received(:by_provider).with(provider) }
      it { expect(expected_return).to have_received(:where).with(id: bidding.id) }
    end

    describe 'return value' do
      before do
        allow(Bidding).to receive(:by_provider).with(provider) { expected_return }
        allow(expected_return).to receive(:where).with(id: bidding.id) { where_return }
      end

      context 'when any' do
        it { expect(subject.allowed?).to be_truthy }
      end

      context 'when empty' do
        let(:where_return) { [] }

        it { expect(subject.allowed?).to be_falsey }
      end
    end
  end
end
