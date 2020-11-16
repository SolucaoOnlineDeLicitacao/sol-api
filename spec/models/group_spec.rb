require 'rails_helper'

RSpec.describe Group, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to :covenant }
    it do
      is_expected.to have_many(:group_items)
      .dependent(:destroy)
      .inverse_of(:group)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }

    context 'associations length' do
      subject { build(:group) }

      context 'when 0' do
        before { subject.group_items.destroy_all; subject.valid? }

        it { is_expected.to be_invalid }
      end

      context 'when > 0' do
        before { subject.valid? }

        it { is_expected.to be_valid }
      end
    end

    context 'uniqueness' do
      it { is_expected.to validate_uniqueness_of(:name).scoped_to(:covenant_id) }
    end
  end

  describe 'nesteds' do
    it { is_expected.to accept_nested_attributes_for(:group_items).allow_destroy(true) }
  end

  describe 'sortable' do
    it { expect(described_class.default_sort_column).to eq 'groups.name' }
  end

  describe 'behaviors' do
    it { is_expected.to be_versionable }
  end
end
