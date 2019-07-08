require 'rails_helper'

RSpec.describe ProviderClassification, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:classification) }
    it { is_expected.to belong_to(:provider) }
  end

  describe 'behaviors' do
    it { is_expected.to be_versionable }
  end
end
