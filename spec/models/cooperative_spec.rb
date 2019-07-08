require 'rails_helper'

RSpec.describe Cooperative, type: :model do
  describe 'associations' do
    it { is_expected.to have_one(:address).dependent(:destroy) }
    it { is_expected.to have_one(:legal_representative).dependent(:destroy) }

    it { is_expected.to have_many(:users).dependent(:destroy) }
    it { is_expected.to have_many(:covenants).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:biddings).through(:covenants) }
    it { is_expected.to have_many(:proposals).through(:biddings) }
    it { is_expected.to have_many(:contracts).through(:proposals) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :cnpj }
    it { is_expected.to validate_presence_of :address }
    it { is_expected.to validate_presence_of :legal_representative }
    it { is_expected.to validate_cnpj_for(:cnpj) }

    context 'name and cnpj uniqueness' do
      before { build(:cooperative) }

      it do
        is_expected.to validate_uniqueness_of(:name)
          .scoped_to(:cnpj).case_insensitive
      end
    end
  end

  describe 'delegations' do
    it { is_expected.to delegate_method(:city_name).to(:address).with_prefix }
    it { is_expected.to delegate_method(:state_name).to(:address).with_prefix }
  end

  describe 'nesteds' do
    it { is_expected.to accept_nested_attributes_for :address }
    it { is_expected.to accept_nested_attributes_for :legal_representative }
  end

  describe 'sortable' do
    it { expect(described_class.default_sort_column).to eq 'cooperatives.name' }
  end

  describe 'addressable' do
    include_examples 'concerns/addressable', :cooperative
  end

  describe 'methods' do
    describe 'text' do
      let(:cooperative) { create(:cooperative) }

      it { expect(cooperative.text).to eq "#{cooperative.name} / #{cooperative.cnpj}"}
    end
  end

  describe 'behaviors' do
    it { is_expected.to be_versionable }
  end
end
