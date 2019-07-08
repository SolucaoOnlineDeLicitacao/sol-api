require 'rails_helper'
require "cancan/matchers"

RSpec.describe Abilities::Strategy, type: :model do
  describe '.call' do
    before do
      allow(Abilities::Admin::ReviewerAbility).to receive(:new).with(user).and_call_original
      allow(Abilities::Admin::GeneralAbility).to receive(:new).with(user).and_call_original
      allow(Abilities::Admin::ViewerAbility).to receive(:new).with(user).and_call_original
      allow(Abilities::SupplierAbility).to receive(:new).with(user).and_call_original
      allow(Abilities::UserAbility).to receive(:new).with(user).and_call_original

      subject
    end

    subject { described_class.call(user: user) }

    context 'when user is nil' do
      let(:user) { nil }

      it { is_expected.to be_nil }
      it { expect(Abilities::Admin::ReviewerAbility).not_to have_received(:new).with(user) }
      it { expect(Abilities::Admin::GeneralAbility).not_to have_received(:new).with(user) }
      it { expect(Abilities::Admin::ViewerAbility).not_to have_received(:new).with(user) }
      it { expect(Abilities::SupplierAbility).not_to have_received(:new).with(user) }
      it { expect(Abilities::UserAbility).not_to have_received(:new).with(user) }
    end

    context 'when is cooperative user' do
      let(:user) { build_stubbed(:user) }

      it { expect(Abilities::Admin::ReviewerAbility).not_to have_received(:new).with(user) }
      it { expect(Abilities::Admin::GeneralAbility).not_to have_received(:new).with(user) }
      it { expect(Abilities::Admin::ViewerAbility).not_to have_received(:new).with(user) }
      it { expect(Abilities::SupplierAbility).not_to have_received(:new).with(user) }
      it { expect(Abilities::UserAbility).to have_received(:new).with(user) }
    end

    context 'when is supplier' do
      let(:user) { build_stubbed(:supplier) }

      it { expect(Abilities::Admin::ReviewerAbility).not_to have_received(:new).with(user) }
      it { expect(Abilities::Admin::GeneralAbility).not_to have_received(:new).with(user) }
      it { expect(Abilities::Admin::ViewerAbility).not_to have_received(:new).with(user) }
      it { expect(Abilities::SupplierAbility).to have_received(:new).with(user) }
      it { expect(Abilities::UserAbility).not_to have_received(:new).with(user) }
    end

    context 'when is admin' do
      context 'and role is nil' do
        let(:user) { build_stubbed(:admin, role: nil) }

        it { is_expected.to be_nil }
        it { expect(Abilities::Admin::ReviewerAbility).not_to have_received(:new).with(user) }
        it { expect(Abilities::Admin::GeneralAbility).not_to have_received(:new).with(user) }
        it { expect(Abilities::Admin::ViewerAbility).not_to have_received(:new).with(user) }
        it { expect(Abilities::SupplierAbility).not_to have_received(:new).with(user) }
        it { expect(Abilities::UserAbility).not_to have_received(:new).with(user) }
      end

      context 'and role is viewer' do
        let(:user) { build_stubbed(:admin, role: :viewer) }

        it { expect(Abilities::Admin::ReviewerAbility).not_to have_received(:new).with(user) }
        it { expect(Abilities::Admin::GeneralAbility).not_to have_received(:new).with(user) }
        it { expect(Abilities::Admin::ViewerAbility).to have_received(:new).with(user) }
        it { expect(Abilities::SupplierAbility).not_to have_received(:new).with(user) }
        it { expect(Abilities::UserAbility).not_to have_received(:new).with(user) }
      end

      context 'and role is general' do
        let(:user) { build_stubbed(:admin, role: :general) }

        it { expect(Abilities::Admin::ReviewerAbility).not_to have_received(:new).with(user) }
        it { expect(Abilities::Admin::GeneralAbility).to have_received(:new).with(user) }
        it { expect(Abilities::Admin::ViewerAbility).not_to have_received(:new).with(user) }
        it { expect(Abilities::SupplierAbility).not_to have_received(:new).with(user) }
        it { expect(Abilities::UserAbility).not_to have_received(:new).with(user) }
      end

      context 'and role is reviewer' do
        let(:user) { build_stubbed(:admin, role: :reviewer) }

        it { expect(Abilities::Admin::ReviewerAbility).to have_received(:new).with(user) }
        it { expect(Abilities::Admin::GeneralAbility).not_to have_received(:new).with(user) }
        it { expect(Abilities::Admin::ViewerAbility).not_to have_received(:new).with(user) }
        it { expect(Abilities::SupplierAbility).not_to have_received(:new).with(user) }
        it { expect(Abilities::UserAbility).not_to have_received(:new).with(user) }
      end
    end
  end
end
