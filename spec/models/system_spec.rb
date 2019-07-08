require 'rails_helper'

RSpec.describe System, type: :model do
  describe 'associations' do
    it { is_expected.to have_one(:contract) }
  end
end
