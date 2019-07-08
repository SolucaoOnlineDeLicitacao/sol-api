require 'rails_helper'

RSpec.describe Event, type: :model do
  subject(:event) { build(:event) }

  context 'factories' do
    it { is_expected.to be_valid }
  end

  context 'associations' do
    it { is_expected.to belong_to :eventable }
    it { is_expected.to belong_to :creator }
  end

  describe 'behaviors' do
    it { is_expected.to be_versionable }
  end
end
