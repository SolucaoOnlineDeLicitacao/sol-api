require 'rails_helper'
require "cancan/matchers"

RSpec.describe Abilities::Admin::ViewerAbility, type: :model do
  let(:user) { build_stubbed(:admin, role: :viewer) }

  subject { described_class.new(user) }

  it { is_expected.to be_able_to(:read, :all) }
  it { is_expected.to be_able_to(:unreads_count, Notification) }
  it { is_expected.to be_able_to(:mark_as_read, Notification) }
  it { is_expected.to be_able_to(:profile, Admin) }
  it { is_expected.to be_able_to(:update, Admin) }
  it { is_expected.to be_able_to(:manage, Report) }

  describe '.as_json' do
    let(:expected) do
      {
        read: ["all"],
        unreads_count: ["Notification"],
        mark_as_read: ["Notification"],
        profile: ["Admin"],
        update: ["Admin"],
        manage: ["Report"]
      }
    end

    it { expect(subject.as_json).to eq expected }
  end
end
