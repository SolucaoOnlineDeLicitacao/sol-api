require 'rails_helper'

RSpec.describe DeviceToken, type: :model do

  describe 'associations' do
    it { is_expected.to belong_to :owner }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :body }
  end
end
