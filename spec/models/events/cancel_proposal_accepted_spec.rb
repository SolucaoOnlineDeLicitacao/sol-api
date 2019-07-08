require 'rails_helper'

RSpec.describe Events::CancelProposalAccepted, type: :model do
  subject { build(:event_cancel_proposal_accepted) }

  context 'factories' do
    it { is_expected.to be_valid }
  end

  context 'validation' do
    let(:invite_statuses) { Proposal.statuses.keys }

    context 'to' do
      it { is_expected.to validate_inclusion_of(:to).in_array(invite_statuses) }
      it { is_expected.to define_data_attr(:to) }
    end

    context 'from' do
      it { is_expected.to validate_inclusion_of(:from).in_array(invite_statuses) }
      it { is_expected.to define_data_attr(:from) }
    end

    it { is_expected.to define_data_attr(:comment) }

    context 'comment' do
      it { is_expected.to validate_presence_of(:comment) }
      it { is_expected.to define_data_attr(:comment) }
    end
  end
end
