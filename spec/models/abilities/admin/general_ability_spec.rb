require 'rails_helper'
require "cancan/matchers"

RSpec.describe Abilities::Admin::GeneralAbility, type: :model do
  let(:user) { build_stubbed(:admin, role: :general) }

  subject { described_class.new(user) }

  context 'when there are integrations' do
    let!(:configuration) { create(:integration_covenant_configuration) }

    [ Covenant, Group, Cooperative, Item, GroupItem ].each do |model|
      it { is_expected.to be_able_to(:read, model) }
    end

    [ Contract, Bidding, Proposal, Lot, LotProposal, Admin, Provider,
      Supplier, Unit, User, Notification, Report].each do |model|
      it { is_expected.to be_able_to(:manage, model) }
    end
  end

  context 'when there are not integrations' do
    [ Covenant, Group, Cooperative, Item, GroupItem, Contract, Bidding,
      Proposal, Lot, LotProposal, Admin, Provider, Supplier, Unit, User,
      Notification, Report ].each do |model|
      it { is_expected.to be_able_to(:manage, model) }
    end
  end

  describe '.as_json' do
    let(:expected) do
      {
        manage: [
          "Covenant", "Group", "Cooperative", "Item", "GroupItem",
          "Contract", "Bidding", "Proposal", "Lot", "LotProposal", "Admin",
          "Provider", "Supplier", "Unit", "User", "Notification", "Report"
        ]
      }
    end

    it { expect(subject.as_json).to eq expected }
  end
end
