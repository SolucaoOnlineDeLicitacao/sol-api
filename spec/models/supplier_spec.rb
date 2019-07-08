require 'rails_helper'

RSpec.describe Supplier, type: :model do
  context 'factories' do
    subject { build :supplier }

    it { is_expected.to be_valid }
  end

  context 'behaviors' do
    it { is_expected.to be_versionable }
  end

  context 'notifiable' do
    include_examples 'concerns/notifiable'
  end

  context 'associations' do
    it { is_expected.to belong_to :provider }
    it { is_expected.to have_one(:contract) }

    it { is_expected.to have_many(:access_tokens).dependent(:destroy) }
    it { is_expected.to have_many(:access_grants).dependent(:destroy) }
    it { is_expected.to have_many(:device_tokens).dependent(:destroy) }
    it { is_expected.to have_many(:lot_proposals).dependent(:restrict_with_error) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :cpf }
    it { is_expected.to validate_presence_of :phone }

    it { is_expected.to validate_phone_for(:phone) }
    it { is_expected.to validate_cpf_for(:cpf) }
  end

  describe 'delegations' do
    it { is_expected.to delegate_method(:name).to(:provider).with_prefix }
  end

  describe 'sortable' do
    it { expect(described_class.default_sort_column).to eq 'suppliers.name' }
  end

  describe 'methods' do
    describe 'text' do
      let(:supplier) { create(:supplier) }

      it { expect(supplier.text).to eq "#{supplier.name} / #{supplier.email}" }
    end
  end
end
