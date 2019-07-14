require 'rails_helper'
require "cancan/matchers"

RSpec.describe Abilities::SupplierAbility, type: :model do
  let(:user) { build_stubbed(:supplier, provider: provider) }

  subject { described_class.new(user) }

  context 'when provider has access' do
    let(:provider) { build_stubbed(:provider, blocked: false) }

    it { expect(subject.permissions[:can]).to be_present }

    describe 'bidding' do
      context 'when policy true' do
        before do
          allow(Policies::Bidding::ManagePolicy).to receive(:allowed?) { true }
        end

        it { is_expected.to be_able_to(:manage, Bidding.new) }
      end

      context 'when policy false' do
        before do
          allow(::Policies::Bidding::ManagePolicy).to receive(:allowed?) { false }
        end

        it { is_expected.not_to be_able_to(:manage, Bidding.new) }
      end
    end

    [ Lot, Contract, Notification, Invite,
      ProposalImport, LotProposalImport, Supplier ].each do |model|
      it { is_expected.to be_able_to(:manage, model) }
    end

    [Proposal, LotProposal].each do |model|
      it { is_expected.to be_able_to(:index, model) }
      it { is_expected.to be_able_to(:show, model) }
      it { is_expected.to be_able_to(:create, model) }
      it { is_expected.to be_able_to(:update, model) }
      it { is_expected.to be_able_to(:destroy, model) }
    end

    it { is_expected.to be_able_to(:finish, Proposal) }
    it { is_expected.to be_able_to(:mark_as_read, Notification) }
  end

  context 'when provider does not have access' do
    let(:provider) { build_stubbed(:provider, blocked: true) }

    it { expect(subject.permissions[:can]).to be_empty }
  end
end
