require 'rails_helper'

RSpec.describe Events::BiddingFailure, type: :model do
  subject { build(:event_bidding_failure) }

  context 'factories' do
    it { is_expected.to be_valid }
  end

  context 'validation' do
    let(:bidding_statuses) { Bidding.statuses.keys }

    context 'from' do
      it { is_expected.to validate_inclusion_of(:from).in_array(bidding_statuses) }
      it { is_expected.to define_data_attr(:from) }
    end

    context 'to' do
      it { is_expected.to validate_inclusion_of(:to).in_array(['failure']) }
      it { is_expected.to define_data_attr(:to) }
    end

    it { is_expected.to define_data_attr(:comment) }

    context 'comment' do
      it { is_expected.to validate_presence_of(:comment) }
      it { is_expected.to define_data_attr(:comment) }
    end
  end
end
