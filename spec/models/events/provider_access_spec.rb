require 'rails_helper'

RSpec.describe Events::ProviderAccess, type: :model do
  subject { build(:event_provider_access) }

  context 'factories' do
    it { is_expected.to be_valid }
    it { is_expected.to define_data_attr(:blocked) }
    it { is_expected.to define_data_attr(:comment) }
  end

  context 'validations' do
    it { is_expected.to validate_inclusion_of(:blocked).in_array([0, 1]) }
    it { is_expected.to validate_presence_of(:comment) }
  end
end
