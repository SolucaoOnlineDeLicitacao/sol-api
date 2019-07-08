require 'rails_helper'

RSpec.describe City, type: :model do

  describe 'associations' do
    it { is_expected.to belong_to(:state) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :code }

    context 'uniqueness' do
      before { build(:state) }

      it { is_expected.to validate_uniqueness_of(:code).case_insensitive }
    end
  end

  describe 'sortable' do
    it { expect(described_class.default_sort_column).to eq 'cities.name' }
  end

  describe 'methods' do
    describe 'text' do
      let(:city) { create(:city) }

      it { expect(city.text).to eq "#{city.name} / #{city.state.uf}"}
    end
  end
end
