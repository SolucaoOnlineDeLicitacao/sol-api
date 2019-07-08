require 'rails_helper'

RSpec.describe Events::InviteReproved, type: :model do
  subject(:event_invite_reproved) { build(:event_invite_reproved) }

  context 'factories' do
    it { is_expected.to be_valid }
  end

  context 'validation' do
    let(:invite_statuses) { Invite.statuses.keys }

    context 'to' do
      it { is_expected.to validate_inclusion_of(:to).in_array(invite_statuses) }
      it { is_expected.to define_data_attr(:to) }
    end

    context 'from' do
      it { is_expected.to validate_inclusion_of(:from).in_array(invite_statuses) }
      it { is_expected.to define_data_attr(:from) }
    end

    it { is_expected.to define_data_attr(:comment) }
  end
end
