require 'rails_helper'

RSpec.describe Invite, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to belong_to(:bidding) }
  end

  describe 'status' do
    let(:invite) { create(:invite) }

    it { expect(invite.approved?).to be true }
  end

  describe 'behaviors' do
    it { is_expected.to be_versionable }
  end
end
