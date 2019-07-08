require 'rails_helper'

RSpec.describe Covenant, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to :admin }
    it { is_expected.to belong_to :cooperative }
    it { is_expected.to belong_to :city }
    it { is_expected.to have_many(:groups).order('groups.name').dependent(:destroy) }
    it { is_expected.to have_many(:group_items).through(:groups) }
    it { is_expected.to have_many(:biddings).dependent(:restrict_with_error) }
  end

  describe 'enums' do
    let(:expected){ %i[waiting running completed canceled] }
    it { is_expected.to define_enum_for(:status).with_values(expected) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :number }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :status }
    it { is_expected.to validate_presence_of :signature_date }
    it { is_expected.to validate_presence_of :validity_date }
    it { is_expected.to validate_presence_of :city }

    context 'uniqueness' do
      it { is_expected.to validate_uniqueness_of(:number).scoped_to(:cooperative_id) }
    end
  end

  describe 'delegations' do
    it { is_expected.to delegate_method(:name).to(:cooperative).with_prefix }
    it { is_expected.to delegate_method(:name).to(:admin).with_prefix }
    it { is_expected.to delegate_method(:text).to(:city).with_prefix }
  end

  describe 'sortable' do
    it { expect(described_class.default_sort_column).to eq 'covenants.number' }
  end

  describe 'callbacks' do
    describe 'before_validation' do
      describe 'ensure_estimated_cost' do
        let(:covenant) { build(:covenant) }

        before { covenant.estimated_cost = '10,05'; covenant.valid? }

        it { expect(covenant.estimated_cost).to eq 10.05 }
      end
    end
  end

  describe 'behaviors' do
    it { is_expected.to be_versionable }
  end
end
