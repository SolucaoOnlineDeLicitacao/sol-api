require 'rails_helper'
require "cancan/matchers"

RSpec.describe Abilities::UserAbility, type: :model do
  let(:user) { build_stubbed(:user) }

  subject { described_class.new(user) }

  [ Provider, Additive, Bidding, Covenant, Contract, LotGroupItem, Proposal,
    LotProposal, Lot, Invite, Group, GroupItem, Notification, User ].each do |model|
    it { is_expected.to be_able_to(:manage, model) }
  end

  it { is_expected.to be_able_to(:mark_as_read, Notification) }
end
