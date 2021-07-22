require 'rails_helper'
require "cancan/matchers"

RSpec.describe Abilities::Admin::ReviewerAbility, type: :model do
  let(:user) { build_stubbed(:admin, role: :reviewer) }

  subject { described_class.new(user) }

  context 'when there are integrations' do
    let!(:configuration) { create(:integration_covenant_configuration) }

    [ Covenant, Group, Cooperative, Item, GroupItem, Admin ].each do |model|
      it { is_expected.to be_able_to(:read, model) }
    end

    [ Contract, Bidding, Proposal, Lot, LotProposal, Provider, Supplier, Unit,
      User, Notification, Report ].each do |model|
      it { is_expected.to be_able_to(:manage, model) }
    end

    it { is_expected.to be_able_to(:profile, Admin) }
    it { is_expected.to be_able_to(:update, Admin) }
    it { is_expected.to be_able_to(:mark_as_read, Notification) }
  end

  context 'when there are not integrations' do
    [ Covenant, Group, Cooperative, Item, GroupItem, Contract, Bidding,
      Proposal, Lot, LotProposal, Provider, Supplier, Unit, User,
      Notification, Report ].each do |model|
      it { is_expected.to be_able_to(:manage, model) }
    end

    it { is_expected.to be_able_to(:read, Admin) }
    it { is_expected.to be_able_to(:profile, Admin) }
    it { is_expected.to be_able_to(:update, Admin) }
    it { is_expected.to be_able_to(:mark_as_read, Notification) }
  end

  describe '.as_json' do
    let(:expected) do
      {
        manage: %w[Covenant Group Cooperative Item GroupItem Contract Bidding Proposal Lot LotProposal Provider Supplier Unit User Notification Report],
        mark_as_read: ["Notification"],
        read: %w[Bidding Admin],
        profile: ["Admin"],
        update: ["Admin"]
      }
    end

    it { expect(subject.as_json).to eq expected }
  end
end
