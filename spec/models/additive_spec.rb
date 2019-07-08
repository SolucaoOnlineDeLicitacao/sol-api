require 'rails_helper'

RSpec.describe Additive, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to :bidding }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :from }
    it { is_expected.to validate_presence_of :to }

    context 'with valid attributes' do
      subject { build(:additive) }

      it { is_expected.to be_valid }
    end

    context "when :to attribute is less than the bid closing date" do
      subject { build(:additive, :with_retroactive_date) }

      it { is_expected.to_not be_valid }
    end

    context 'when there is no bidding' do
      subject { build(:additive, bidding: nil) }

      it { is_expected.to_not be_valid }
    end

    describe 'retroactive_date' do
      let(:bidding) { build(:bidding, closing_date: Date.current ) }
      subject { build(:additive, bidding: bidding, to: to) }

      before { subject.valid? }

      context 'when < current bidding closing date' do
        let!(:to) { Date.yesterday }

        it { is_expected.to include_error_key_for(:to, :invalid) }
      end

      context 'when = current bidding closing date' do
        let!(:to) { Date.current }

        it { is_expected.to include_error_key_for(:to, :invalid) }
      end

      context 'when > current bidding closing date' do
        let!(:to) { Date.tomorrow }

        it { is_expected.not_to include_error_key_for(:to, :invalid) }
      end
    end
  end

  describe 'behaviors' do
    it { is_expected.to be_versionable }
  end
end
