require 'rails_helper'

RSpec.describe State, type: :model do

  describe 'associations' do
    it { is_expected.to have_many(:cities).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :uf }
    it { is_expected.to validate_presence_of :code }

    context 'uniqueness' do
      before { build(:state) }

      it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
      it { is_expected.to validate_uniqueness_of(:uf).case_insensitive }
      it { is_expected.to validate_uniqueness_of(:code) }
    end
  end
end
