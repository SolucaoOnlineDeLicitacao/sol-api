require 'rails_helper'

RSpec.describe Unit, type: :model do
  describe 'associations' do
    it { is_expected.to have_many :items }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    
    context 'uniqueness' do
      before { build(:unit) }

      it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    end
  end

  describe 'sortable' do
    it { expect(described_class.default_sort_column).to eq 'units.name' }
  end
end
