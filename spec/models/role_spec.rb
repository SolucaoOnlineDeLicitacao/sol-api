require 'rails_helper'

RSpec.describe Role, type: :model do

  describe 'validations' do
    it { is_expected.to validate_presence_of :title }

    context 'uniqueness' do
      before { build(:role) }

      it { is_expected.to validate_uniqueness_of(:title).case_insensitive }
    end
  end

  describe 'sortable' do
    it { expect(described_class.default_sort_column).to eq 'roles.title' }
  end

  describe 'methods' do
    describe 'text' do
      let(:role) { create(:role) }

      it { expect(role.text).to eq role.title }
    end
  end
end
