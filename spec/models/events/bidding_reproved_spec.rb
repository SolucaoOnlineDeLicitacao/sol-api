require 'rails_helper'

RSpec.describe Events::BiddingReproved, type: :model do
  subject(:event_bidding_reproved) { build(:event_bidding_reproved) }

  context 'factories' do
    it { is_expected.to be_valid }
  end

  context 'validation' do
    let(:bidding_statuses) { %w(draft waiting) }

    context 'to' do
      it { is_expected.to validate_inclusion_of(:to).in_array(bidding_statuses) }
      it { is_expected.to define_data_attr(:to) }
    end

    context 'from' do
      it { is_expected.to validate_inclusion_of(:from).in_array(bidding_statuses) }
      it { is_expected.to define_data_attr(:from) }
    end

    it { is_expected.to define_data_attr(:comment) }
  end
end
